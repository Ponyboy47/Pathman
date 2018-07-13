import Cdirent

#if os(Linux)
typealias DIRType = OpaquePointer
#else
typealias DIRType = UnsafeMutablePointer<DIR>
#endif

private let dirConditions: Conditions = .newer(than: .seconds(5), threshold: 0.25, minCount: 50)

private var _openDirectories: DateSortedDescriptors<DirectoryPath, OpenDirectory> = [:]
private var openDirectories: DateSortedDescriptors<DirectoryPath, OpenDirectory> {
    get {
        if _openDirectories.autoclose == nil {
            _openDirectories.autoclose = (percentage: 0.1, conditions: dirConditions, priority: .added, min: -1.0, max: -1.0)
        }
        return _openDirectories
    }
    set {
        _openDirectories = newValue
        autoclose(_openDirectories, percentage: 0.1, conditions: dirConditions)
        _openDirectories.autoclose = (percentage: 0.1, conditions: dirConditions, priority: .added, min: -1.0, max: -1.0)
    }
}

/// A Path to a directory
public class DirectoryPath: _Path, Openable, Sequence, IteratorProtocol {
    public typealias OpenableType = DirectoryPath

    public internal(set) var path: String
    public var fileDescriptor: FileDescriptor {
        guard let dir = self.dir else { return -1 }
        return dirfd(dir)
    }
    private var dir: DIRType?
    private var finishedTraversal: Bool = false
    public internal(set) var options: OptionInt = 0
    public internal(set) var mode: FileMode? = nil

    // This is to protect the info from being set externally
    private var _info: StatInfo
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /// Initialize from an array of path elements
    public required init?(_ components: [String]) {
        path = components.filter({ !$0.isEmpty && $0 != DirectoryPath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == DirectoryPath.separator {
            path = first + path
        }
        _info = StatInfo(path)

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
            path = String(str.dropLast())
        } else {
            path = str
        }
        _info = StatInfo(path)

        if exists {
            guard isDirectory else { return nil }
        }
    }

    public required init?<PathType: Path>(_ path: PathType) {
        // Cannot initialize a directory from a file
        guard PathType.self != FilePath.self else { return nil }

        self.path = path.path
        self._info = path.info

        if exists {
            guard isDirectory else { return nil }
        }
    }

    @discardableResult
    public func open(options: OptionInt = 0, mode: FileMode? = nil) throws -> Open<DirectoryPath> {
        // If the directory is already open, return it
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
	public func children(includeHidden: Bool = false) throws -> DirectoryChildren {
        return try recursiveChildren(to: 1, includeHidden: includeHidden)
    }


    /**
     Recursively iterates through and retrives all children in all subdirectories

     - Parameter depth: How many subdirectories may be recursively traversed (-1 for infinite depth)
     - Parameter includeHidden: Whether or not to include hidden files and traverse hidden directories
     - Throws: When it fails to open or close any of the subdirectories
     - WARNING: If the directory you're traversing is exceptionally large and/or deep, then this will take a very long time and will use a large amount of memory and you may run out of available file descriptors. Until I can figure out how to do this lazily, be careful with using infinite recursion (a depth of -1) or with depths greater than the available number of process descriptors.
     */
    public func recursiveChildren(depth: Int = -1, includeHidden: Bool = false) throws -> DirectoryChildren {
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
    private func recursiveChildren(to depth: Int, includeHidden: Bool) throws -> DirectoryChildren {
        var children: DirectoryChildren = DirectoryChildren()
        // Make sure we're not below the specified depth
        guard depth != 0 else { return children }
        let depth = depth == -1 ? depth : depth - 1

        // Make sure the directory has been opened
        let unopened = dir == nil
        if unopened {
            try open()
        }

        // Go through all the paths in the current directory and add them to the correct array
        for path in self {
            if !includeHidden {
                guard !path.lastComponent.hasPrefix(".") else { continue }
            }

            if let file = FilePath(path) {
                children.files.append(file)
            } else if let dir = DirectoryPath(path) {
                children.directories.append(dir)
                // Make sure we're safe to go another level deep
                if depth != 0 {
                    guard !["..", "."].contains(dir.lastComponent) else { continue }
                    children += try dir.recursiveChildren(to: depth, includeHidden: includeHidden)
                    if self.dir == nil {
                        try open()
                    }
                }
            } else {
                children.other.append(path)
            }
        }

        // If this directory was previously unopened and we only opened it for
        // this operation, then we should go ahead and close it too
        if unopened {
            try close()
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
        let name = withUnsafeBytes(of: &ent.pointee.d_name) { (ptr) -> String in
            guard let charPtr = ptr.baseAddress?.assumingMemoryBound(to: CChar.self) else { return "" }
            return String(cString: charPtr)
        }

        return self + name
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

public struct DirectoryChildren: Equatable, CustomStringConvertible {
    public fileprivate(set) var files: [FilePath]
    public fileprivate(set) var directories: [DirectoryPath]
    public fileprivate(set) var other: [GenericPath]

    public var description: String {
        var str: [String] = []
        if !files.isEmpty {
            str.append("files:\n\t\(files.map { $0.string } )")
        }
        if !directories.isEmpty {
            str.append("directories:\n\t\(directories.map { $0.string } )")
        }
        if !other.isEmpty {
            str.append("other:\n\t\(other.map { $0.string } )")
        }
        return str.joined(separator: "\n\n")
    }

    public var prettyPrint: String {
        var str: [String] = []
        if !files.isEmpty {
            str.append("files:\n\t\(files.map({ $0.string }).joined(separator: "\n\t"))")
        }
        if !directories.isEmpty {
            str.append("directories:\n\t\(directories.map({ $0.string }).joined(separator: "\n\t"))")
        }
        if !other.isEmpty {
            str.append("other:\n\t\(other.map({ $0.string }).joined(separator: "\n\t"))")
        }
        return str.joined(separator: "\n\n")
    }

    init(files: [FilePath] = [], directories: [DirectoryPath] = [], other: [GenericPath] = []) {
        self.files = files
        self.directories = directories
        self.other = other
    }

    public static func += (lhs: inout DirectoryChildren, rhs: DirectoryChildren) {
        lhs.files += rhs.files
        lhs.directories += rhs.directories
        lhs.other += rhs.other
    }

    public static func == (lhs: DirectoryChildren, rhs: DirectoryChildren) -> Bool {
        return lhs.files == rhs.files && lhs.directories == rhs.directories && lhs.other == rhs.other
    }
}
