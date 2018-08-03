import Cdirent

#if os(Linux)
typealias DIRType = OpaquePointer
#else
typealias DIRType = UnsafeMutablePointer<DIR>
#endif

/*
Recently modified the recursive functions to only have one directory open at
a time. This should prevent the need for the whole autoclose code (and its
overhead)

/// The conditions under which large amounts of rapidly opened directories
/// are automatically closed (to prevent using up all the process's/system's
/// available file descriptors)
private let dirConditions: Conditions = .newer(than: .seconds(5), threshold: 0.25, minCount: 50)

/// The date sorted collection of open directories
private var _openDirectories: DateSortedDescriptors<DirectoryPath, OpenDirectory> = [:]
/// The date sorted collection of open directories
private var openDirectories: DateSortedDescriptors<DirectoryPath, OpenDirectory> {
    get {
        if _openDirectories.autoclose == nil {
            _openDirectories.autoclose = (percentage: 0.1, conditions: dirConditions, priority: .added, min: -1.0, max: -1.0)
        }
        return _openDirectories
    }
    set {
        _openDirectories = newValue
        // See if we should close any recently opened directories
        // NOTE: The openDirectories object calls autoclose when inserting
        // new items, but this is used when completely reassigning
        // openDirectories
        autoclose(openDirectories, percentage: 0.1, conditions: dirConditions)
    }
}
*/

/// A dictionary of all the open directories
private var openDirectories: [DirectoryPath: OpenDirectory] = [:]

/// A Path to a directory
public class DirectoryPath: Path, Openable, Sequence, IteratorProtocol {
    public typealias OpenableType = DirectoryPath

    public var _path: String
    public var fileDescriptor: FileDescriptor {
        // Opened directories result in a DIR struct, rather than a straight
        // file descriptor. The dirfd(3) C API call takes a DIR pointer and
        // returns its associated file descriptor

        // Make sure we have opened the directory, otherwise return -1
        guard let dir = self.dir else { return -1 }

        // Either returns the file descriptor or -1 if there was an error
        return dirfd(dir)
    }

    /// Opening a directory returns a pointer to a DIR struct
    private var dir: DIRType?
    /// Directories need to be rewound after being traversed. This tracks
    /// whether or not we need to rewind a directory
    private var finishedTraversal: Bool = false

    /// The options used to open a directory (Ignored)
    public internal(set) var options: OptionInt = 0
    /// The mode used to open a directory (Ignored)
    public internal(set) var mode: FileMode? = nil

    // This is to protect the info from being set externally
    private var _info: StatInfo
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /// Initialize from an array of path elements
    public required init?(_ components: [String]) {
        _path = components.filter({ !$0.isEmpty && $0 != DirectoryPath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == DirectoryPath.separator {
            _path = first + _path
        }
        _info = StatInfo(_path)

        if exists {
            guard isDirectory else { return nil }
        }
    }

    /// Initialize from a variadic array of path elements
    public convenience init?(_ components: String...) {
        self.init(components)
    }

    /// Initialize from a slice of an array of path elements
    public convenience init?(_ components: ArraySlice<String>) {
        self.init(Array(components))
    }

    public required init?(_ str: String) {
        if str.count > 1 && str.hasSuffix(DirectoryPath.separator) {
            _path = String(str.dropLast())
        } else {
            _path = str
        }
        _info = StatInfo(_path)

        if exists {
            guard isDirectory else { return nil }
        }
    }

    /**
    Initialize from another DirectoryPath (copy constructor)

    - Parameter path: The path to copy
    */
    public init(_ path: DirectoryPath) {
        _path = path._path
        _info = path.info
    }

    /**
    Initialize from another Path

    - Parameter path: The path to copy
    */
    public required init?(_ path: GenericPath) {
        // Cannot initialize a directory from a non-directory type
        if path.exists {
            guard path.isDirectory else { return nil }
        }

        _path = path._path
        _info = path.info
    }

    /**
    */
    @discardableResult
    public func open(options: OptionInt = 0, mode: FileMode? = nil) throws -> Open<DirectoryPath> {
        // If the directory is already open, return it. Unlike FilePaths, the
        // options/mode are irrelevant for opening directories
        if let openDir = openDirectories[self] {
            return openDir
        }

        dir = opendir(string)

        guard dir != nil else {
            throw OpenDirectoryError.getError()
        }

        // Add the newly opened directory to the openDirectories dict
        let openDir = Open(self)
        openDirectories[self] = openDir
        return openDir
    }

    public func close() throws {
        guard let dir = self.dir else { return }

        // Be sure to remove the open directory from the dict
        defer {
            // When this line was not first, it was not executed for some reason
            self.dir = nil
            openDirectories.removeValue(forKey: self)
        }

        guard closedir(dir) != -1 else {
            throw CloseDirectoryError.getError()
        }
    }

    /**
     Retrieves and files or directories contained within the directory

     - Throws: When it fails to open or close the directory
    */
	public func children(includeHidden: Bool = false) throws -> PathCollection {
        return try recursiveChildren(to: 1, includeHidden: includeHidden)
    }


    /**
     Recursively iterates through and retrives all children in all subdirectories

     - Parameter depth: How many subdirectories may be recursively traversed (-1 for infinite depth)
     - Parameter includeHidden: Whether or not to include hidden files and traverse hidden directories
     - Throws: When it fails to open or close any of the subdirectories
     - WARNING: If the directory you're traversing is exceptionally large and/or deep, then this will take a very long time and will use a large amount of memory and you may run out of available file descriptors. Until I can figure out how to do this lazily, be careful with using infinite recursion (a depth of -1) or with depths greater than the available number of process descriptors.
     */
    public func recursiveChildren(depth: Int = -1, includeHidden: Bool = false) throws -> PathCollection {
        return try recursiveChildren(to: depth, includeHidden: includeHidden)
    }

    /**
     Recursively iterates through and retrives all children in all subdirectories

     - Parameter depth: How many subdirectories may be recursively traversed (-1 for infinite depth)
     - Parameter includeHidden: Whether or not to include hidden files and traverse hidden directories
     - Throws: When it fails to open or close any of the subdirectories
     - WARNING: If the directory you're traversing is exceptionally large and/or deep, then this will take a very long time and will use a large amount of memory and you may run out of available file descriptors. Until I can figure out how to do this lazily, be careful with using infinite recursion (a depth of -1) or with depths greater than the available number of process descriptors.
     */
    @discardableResult
    private func recursiveChildren(to depth: Int, includeHidden: Bool) throws -> PathCollection {
        var children: PathCollection = PathCollection()
        // Make sure we're not below the specified depth
        guard depth != 0 else { return children }
        let depth = depth - 1

        // Make sure the directory has been opened
        let unopened = dir == nil
        // If the directory is already open, this just returns the opened directory
        try open()

        // Go through all the paths in the current directory and add them to the correct array
        for path in self {
            if !includeHidden {
                guard !(path.lastComponent ?? "").hasPrefix(".") else { continue }
            }

            if let file = FilePath(path) {
                children.files.append(file)
            } else if let dir = DirectoryPath(path) {
                children.directories.append(dir)
            } else {
                children.other.append(path)
            }
        }

        // If this directory was previously unopened and we only opened it for
        // this operation, then we should go ahead and close it too
        if unopened {
            try close()
        }

        if depth != 0 {
            let dirs = children.directories
            for dir in dirs {
                children += try dir.recursiveChildren(to: depth, includeHidden: includeHidden)
            }
        }

        return children
    }

    public func recursiveDelete() throws {
        guard exists else { return }

        let unopened = dir == nil
        if unopened {
            try open()
        }

        for path in self {
            if let file = FilePath(path) {
                try file.delete()
            } else if let dir = DirectoryPath(path) {
                guard !["..", "."].contains(dir.lastComponent) else { continue }
                try dir.recursiveDelete()
            } else {
                break
            }
        }

        if unopened {
            try close()
        }

        try delete()
    }

    public func next() -> GenericPath? {
        guard let dir = self.dir else { return nil }
        if finishedTraversal {
            rewinddir(dir)
            finishedTraversal = false
        }
        guard let ent = readdir(dir) else {
            finishedTraversal = true
            return nil
        }
        return genPath(ent)
    }

    private func genPath(_ ent: UnsafeMutablePointer<dirent>) -> GenericPath {
        let name = withUnsafePointer(to: &ent.pointee.d_name) { (ptr) -> String in
            return ptr.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: ent.pointee.d_name)) {
                return String(cString: $0)
            }
        }

        return self + name
    }

    public func changeRecursive(owner uid: uid_t = ~0, group gid: gid_t = ~0) throws {
        guard exists else { return }

        try change(owner: uid, group: gid)

        let unopened = dir == nil
        if unopened {
            try open()
        }

        for path in self {
            if let dir = DirectoryPath(path) {
                guard !["..", "."].contains(dir.lastComponent) else { continue }
                try dir.changeRecursive(owner: uid, group: gid)
            } else {
                try path.change(owner: uid, group: gid)
            }
        }

        if unopened {
            try close()
        }
    }

    public func changeRecursive(owner username: String? = nil, group groupname: String? = nil) throws {
        let uid: uid_t
        let gid: gid_t

        if let username = username {
            guard let _uid = getUserInfo(username)?.pw_uid else { throw UserInfoError.getError() }
            uid = _uid
        } else {
            uid = ~0
        }

        if let groupname = groupname {
            guard let _gid = getGroupInfo(groupname)?.gr_gid else { throw GroupInfoError.getError() }
            gid = _gid
        } else {
            gid = ~0
        }

        try changeRecursive(owner: uid, group: gid)
    }

    public func changeRecursive(permissions: FileMode) throws {
        guard exists else { return }

        try change(permissions: permissions)

        let unopened = dir == nil
        if unopened {
            try open()
        }

        for path in self {
            if let dir = DirectoryPath(path) {
                guard !["..", "."].contains(dir.lastComponent) else { continue }
                try dir.changeRecursive(permissions: permissions)
            } else {
                try path.change(permissions: permissions)
            }
        }

        if unopened {
            try close()
        }
    }

    public func changeRecursive(owner: FilePermissions, group: FilePermissions, others: FilePermissions, bits: FileBits) throws {
        try changeRecursive(permissions: FileMode(owner: owner, group: group, others: others, bits: bits))
    }

    public func changeRecursive(owner: FilePermissions? = nil, group: FilePermissions? = nil, others: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try changeRecursive(owner: owner ?? current.owner, group: group ?? current.group, others: others ?? current.others, bits: bits ?? current.bits)
    }

    public func changeRecursive(ownerGroup perms: FilePermissions, others: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try changeRecursive(owner: perms, group: perms, others: current.others, bits: bits ?? current.bits)
    }

    public func changeRecursive(ownerOthers perms: FilePermissions, group: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try changeRecursive(owner: perms, group: group ?? current.group, others: perms, bits: bits ?? current.bits)
    }

    public func changeRecursive(groupOthers perms: FilePermissions, owner: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try changeRecursive(owner: owner ?? current.owner, group: perms, others: perms, bits: bits ?? current.bits)
    }

    public func changeRecursive(ownerGroupOthers perms: FilePermissions, bits: FileBits? = nil) throws {
        try changeRecursive(owner: perms, group: perms, others: perms, bits: bits ?? permissions.bits)
    }

    public static func + (lhs: DirectoryPath, rhs: String) -> GenericPath {
        return lhs + GenericPath(rhs)
    }

    public static func + <PathType: Path>(lhs: DirectoryPath, rhs: PathType) -> PathType {
        var newPath = lhs.string
        let right = rhs.string

        if !newPath.hasSuffix(DirectoryPath.separator) {
            newPath += DirectoryPath.separator
        }

        if right.hasPrefix(DirectoryPath.separator) {
            newPath += right.dropFirst()
        } else {
            newPath += right
        }

        guard let new = PathType(newPath) else {
            fatalError("Failed to instantiate \(PathType.self) from \(Swift.type(of: newPath)) '\(newPath)'")
        }
        return new
    }

    public static func += (lhs: inout DirectoryPath, rhs: DirectoryPath) {
        lhs = lhs + rhs
    }

    @available(*, unavailable, message: "Appending FilePath to DirectoryPath results in a FilePath, but it is impossible to change the type of the left-hand object from a DirectoryPath to a FilePath")
    public static func += (lhs: inout DirectoryPath, rhs: FilePath) {}

    deinit {
        try? close()
    }
}
