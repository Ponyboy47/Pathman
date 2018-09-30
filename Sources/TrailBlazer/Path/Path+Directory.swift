import Cdirent

#if os(Linux)
/// The directory stream type used for readding directory entries
typealias DIRType = OpaquePointer
#else
/// The directory stream type used for readding directory entries
typealias DIRType = UnsafeMutablePointer<DIR>
#endif

/// A dictionary of all the open directories
private var openDirectories: [DirectoryPath: OpenDirectory] = [:]

public struct DirectoryEnumerationOptions: OptionSet {
    public let rawValue: UInt8

    public static let includeHidden = DirectoryEnumerationOptions(rawValue: 1 << 0)

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

/// A Path to a directory
public class DirectoryPath: Path, Openable, Linkable {
    public typealias OpenableType = DirectoryPath

    public var _path: String
    public var fileDescriptor: FileDescriptor {
        // Opened directories result in a DIR struct, rather than a straight
        // file descriptor. The dirfd(3) C API call takes a DIR pointer and
        // returns its associated file descriptor

        // Either returns the file descriptor or -1
        return dir == nil ? -1 : dirfd(dir!)
    }

    /// Opening a directory returns a pointer to a DIR struct
    private var dir: DIRType? {
        didSet {
            if dir != nil {
                opened = Open(self)
            } else {
                opened = nil
            }
        }
    }
    /// Directories need to be rewound after being traversed. This tracks
    /// whether or not we need to rewind a directory
    private var finishedTraversal: Bool = false

    /// The currently opened directory (if it has been opened previously)
    /// Warning: The setter may be removed in a later release
    public var opened: OpenDirectory? {
        get { return openDirectories[self] }
        set {
            openDirectories[self] = newValue
        }
    }

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
    public required init(_ path: DirectoryPath) {
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
    Opens the directory

    - Returns: The opened directory

    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    @discardableResult
    public func open() throws -> Open<DirectoryPath> {
        // If the directory is already open, return it. Unlike FilePaths, the
        // options/mode are irrelevant for opening directories
        if let openDir = opened {
            return openDir
        }

        dir = opendir(string)

        guard dir != nil else {
            throw OpenDirectoryError.getError()
        }

        return opened !! "Failed to set the open directory"
    }

    /**
    Closes the directory, if open

    - Throws: Never
    */
    public func close() throws {
        guard let dir = self.dir else { return }

        // Be sure to remove the open directory from the dict
        defer {
            // When this line was not first, it was not executed for some reason
            self.dir = nil
        }

        // This should never throw since self.dir is private and the only way
        // it would be invalid is if it was previously closed or set to nil
        // (which this library should never do)
        guard closedir(dir) != -1 else {
            throw CloseDirectoryError.getError()
        }
    }

    /**
    Retrieves and files or directories contained within the directory

    - Parameter options: The options used while enumerating the children of the directory

    - Returns: A PathCollection of all the files, directories, and other paths that are contained in self
    - Note: Opens the directory if it is unopened and will close it afterwards if the directory was only opened for this API call

    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func children(options: DirectoryEnumerationOptions = []) throws -> PathCollection {
        return try recursiveChildren(to: 1, options: options)
    }

    /**
    Recursively iterates through and retrives all children in all subdirectories

    - Parameter depth: How many subdirectories may be recursively traversed (-1 for infinite depth)
    - Parameter options: The options used while enumerating the children of the directory

    - Returns: A PathCollection of all the files, directories, and other paths that are contained in self and its subdirectories
    - Note: Opens any directories that are previously unopened and will close them afterwards if it was only opened for this API call

    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func recursiveChildren(depth: Int = -1, options: DirectoryEnumerationOptions = []) throws -> PathCollection {
        return try recursiveChildren(to: depth, options: options)
    }

    /**
    Recursively iterates through and retrives all children in all subdirectories

    - Parameter depth: How many subdirectories may be recursively traversed (-1 for infinite depth)
    - Parameter options: The options used while enumerating the children of the directory

    - Returns: A PathCollection of all the files, directories, and other paths that are contained in self and its subdirectories
    - Note: Opens any directories that are previously unopened and will close them afterwards if it was only opened for this API call

    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    @discardableResult
    private func recursiveChildren(to depth: Int, options: DirectoryEnumerationOptions) throws -> PathCollection {
        var children: PathCollection = PathCollection()
        // Make sure we're not below the specified depth
        guard depth != 0 else { return children }
        let depth = depth - 1

        // Make sure the directory has been opened
        let unopened = self.dir == nil
        // If the directory is already open, this just returns the opened directory
        try open()

        let dir = self.dir !! "Failed to open a directory without throwing an error!"

        // Go through all the paths in the current directory and add them to the correct array
        repeat {
            guard let path = nextPath(from: dir) else { break }
            guard !["..", "."].contains(path.lastComponent) else { continue }

            if !options.contains(.includeHidden) {
                guard !(path.lastComponent ?? "").hasPrefix(".") else { continue }
            }

            if let file = FilePath(path) {
                children.files.append(file)
            } else if let dir = DirectoryPath(path) {
                children.directories.append(dir)
            } else {
                children.other.append(path)
            }
        } while true

        // If this directory was previously unopened and we only opened it for
        // this operation, then we should go ahead and close it too
        if unopened {
            try close()
        }

        if depth != 0 {
            let dirs = children.directories
            for dir in dirs {
                children += try dir.recursiveChildren(to: depth, options: options)
            }
        }

        return children
    }

    /**
    Recursively deletes every path inside and below self

    - Warning: This cannot be undone and should be used with extreme caution
    - Note: In order to know which paths are being deleted, every directory that is encountered must be opened and, as a result, may throw

    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    - Throws: `DeleteDirectoryError.permissionDenied` when the calling process doesn't have write access to the directory containing the path or the calling process does not have search permissions to one of the path's components
    - Throws: `DeleteDirectoryError.directoryInUse` when the directory is currently in use by the system or some process that prevents its removal. On linux this means the path is being used as a mount point or is the root directory of the calling process
    - Throws: `DeleteDirectoryError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `DeleteDirectoryError.relativePath` when the last path component is '.'
    - Throws: `DeleteDirectoryError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `DeleteDirectoryError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `DeleteDirectoryError.noRouteToPath` when the path could not be resolved
    - Throws: `DeleteDirectoryError.pathComponentNotDirectory` when a component of the path was not a directory
    - Throws: `DeleteDirectoryError.noKernelMemory` when there is no available memory to delete the directory
    - Throws: `DeleteDirectoryError.readOnlyFileSystem` when the file system is in read-only mode and so the directory cannot be deleted
    - Throws: `DeleteDirectoryError.ioError` (macOS only) when an I/O error occurred during the API call
    - Throws: `GenericDeleteError.cannotDeleteGenericPath` when the path is a type that is not Deletable. If you encounter this error, please log an issue on GitHub so I can add support for deleting the path type
    - Throws: `DeleteFileError.permissionDenied` when the calling process does not have write access to the directory containing the path or the calling process does not have search permissions to one of the path's components or the calling process does not have permission to delete the path
    - Throws: `DeleteFileError.pathInUse` when the path is in use by the system or another process
    - Throws: `DeleteFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `DeleteFileError.ioError` when an I/O error occurred
    - Throws: `DeleteFileError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `DeleteFileError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `DeleteFileError.noKernelMemory` when there is no available mermory to delete the file
    - Throws: `DeleteFileError.readOnlyFileSystem` when the file system is in read-only mode and so the file cannot be deleted
    - Throws: `CloseFileError.badFileDescriptor` when the file descriptor isn't open or valid (should only occur if you're manually closing it outside of the normal TrailBlazer API)
    - Throws: `CloseFileError.interruptedBySignal` when a signal interrupts the API call
    - Throws: `CloseFileError.ioError` when an I/O error occurred during the API call
    */
    public func recursiveDelete() throws {
        let childPaths = try children(options: .includeHidden)

        // Throw an error if the path can't be deleted or else a DeleteDirectoryError.directoryNotEmpty error will be thrown later
        guard childPaths.other.isEmpty else {
            throw GenericDeleteError.cannotDeleteGenericPath(childPaths.other.first!)
        }

        // Delete all the files
        for file in childPaths.files {
            try file.delete()
        }

        // Recursively delete any subdirectories
        for directory in childPaths.directories {
            try directory.recursiveDelete()
        }

        // Now that the directory is empty, delete it
        try delete()
    }

    /**
    Iterates through self

    - Returns: The next path in the directory or nil if all paths have been returned
    */
    private func nextPath(from dir: DIRType) -> GenericPath? {
        // If we've iterated through and we're starting again, rewind the directory stream and reset finishedTraversal
        if finishedTraversal {
            // Points the directory stream back to the first path in the directory
            rewind()
        }

        // Read the next entry in the directory. This C API call should never
        // fail (as long as the DIR property is private)
        guard let entry = readdir(dir) else {
            // If entry is nil then we've read all the entries in the directory
            finishedTraversal = true
            return nil
        }

        // Pulls the directory path from the C dirent struct
        return genPath(entry)
    }

    private func rewind() {
        guard let dir = self.dir else { return }

        defer { finishedTraversal = false }
        rewinddir(dir)
    }

    /**
    Generates a GenericPath from the given dirent pointer

    - Parameter ent: A pointer to the C dirent struct containing the path to generate
    - Returns: A GenericPath to the item pointed to in the dirent struct
    */
    private func genPath(_ ent: UnsafeMutablePointer<dirent>) -> GenericPath {
        // Get the path name (last path component) from the C dirent struct.
        // char[256] in C is converted to a 256 item tuple in Swift. This
        // block converts that to an char * array that can be used to
        // initialize a Swift String using the cString initializer
        let name = withUnsafePointer(to: &ent.pointee.d_name) { (ptr) -> String in
            return ptr.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: ent.pointee.d_name)) {
                return String(cString: $0)
            }
        }

        // The full path is the concatenation of self with the path name
        return self + name
    }

    /**
    Recursively changes the owner and group of all files and subdirectories

    - Parameter owner: The uid of the owner of the path
    - Parameter group: The gid of the group with permissions to access the path
    - Parameter options: The options used while enumerating the children of the directory

    - Throws: `ChangeOwnershipError.permissionDenied` when the calling process does not have the proper permissions to modify path ownership
    - Throws: `ChangeOwnershipError.badAddress` when the path points to a location outside your addressible address space
    - Throws: `ChangeOwnershipError.tooManySymlinks` when too many symlinks were encounter while resolving the path
    - Throws: `ChangeOwnershipError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangeOwnershipError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangeOwnershipError.noKernelMemory` when there is insufficient memory to change the path's ownership
    - Throws: `ChangeOwnershipError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangeOwnershipError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `ChangeOwnershipError.ioError` when an I/O error occurred during the API call
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func changeRecursive(owner uid: uid_t = ~0, group gid: gid_t = ~0, options: DirectoryEnumerationOptions = .includeHidden) throws {
        let childPaths = try children(options: options)

        for file in childPaths.files {
            try file.change(owner: uid, group: gid)
        }

        for path in childPaths.other {
            try path.change(owner: uid, group: gid)
        }

        for directory in childPaths.directories {
            try directory.changeRecursive(owner: uid, group: gid)
        }

        try change(owner: uid, group: gid)
    }

    /**
    Recursively changes the owner and group of all files and subdirectories

    - Parameter owner: The username of the owner of the path
    - Parameter group: The name of the group with permissions to access the path
    - Parameter options: The options used while enumerating the children of the directory

    - Throws: `ChangeOwnershipError.permissionDenied` when the calling process does not have the proper permissions to modify path ownership
    - Throws: `ChangeOwnershipError.badAddress` when the path points to a location outside your addressible address space
    - Throws: `ChangeOwnershipError.tooManySymlinks` when too many symlinks were encounter while resolving the path
    - Throws: `ChangeOwnershipError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangeOwnershipError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangeOwnershipError.noKernelMemory` when there is insufficient memory to change the path's ownership
    - Throws: `ChangeOwnershipError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangeOwnershipError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `ChangeOwnershipError.ioError` when an I/O error occurred during the API call
    - Throws: `UserInfoError.userDoesNotExist` when there was no user found with the specified username
    - Throws: `UserInfoError.interruptedBySignal` when the API call was interrupted by a signal handler
    - Throws: `UserInfoError.ioError` when an I/O error occurred during the API call
    - Throws: `UserInfoError.noMoreProcessFileDescriptors` when the process has no more available file descriptors
    - Throws: `UserInfoError.noMoreSystemFileDescriptors` when the system has no more available file descriptors
    - Throws: `UserInfoError.outOfMemory` when there is insufficient memory to allocate the underlying C passwd struct
    - Throws: `GroupInfoError.groupDoesNotExist` when there was no group found with the specified name
    - Throws: `GroupInfoError.interruptedBySignal` when the API call was interrupted by a signal handler
    - Throws: `GroupInfoError.ioError` when an I/O error occurred during the API call
    - Throws: `GroupInfoError.noMoreProcessFileDescriptors` when the process has no more available file descriptors
    - Throws: `GroupInfoError.noMoreSystemFileDescriptors` when the system has no more available file descriptors
    - Throws: `GroupInfoError.outOfMemory` when there is insufficient memory to allocate the underlying C group struct
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func changeRecursive(owner username: String? = nil, group groupname: String? = nil, options: DirectoryEnumerationOptions = .includeHidden) throws {
        let uid: uid_t
        let gid: gid_t

        if let username = username {
            uid = try getUserInfo(username).pw_uid
        } else {
            uid = ~0
        }

        if let groupname = groupname {
            gid = try getGroupInfo(groupname).gr_gid
        } else {
            gid = ~0
        }

        try changeRecursive(owner: uid, group: gid, options: options)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameter permissions: The new permissions for the paths
    - Parameter options: The options used while enumerating the children of the directory

    - Throws: `ChangePermissionsError.permissionDenied` when the calling process does not have the proper permissions to modify path permissions
    - Throws: `ChangePermissionsError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `ChangePermissionsError.ioError` when an I/O error occurred during the API call
    - Throws: `ChangePermissionsError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `ChangePermissionsError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangePermissionsError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangePermissionsError.noKernelMemory` when there is insufficient memory to change the path's permissions
    - Throws: `ChangePermissionsError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangePermissionsError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func changeRecursive(permissions: FileMode, options: DirectoryEnumerationOptions = .includeHidden) throws {
        let childPaths = try children(options: options)

        for file in childPaths.files {
            try file.change(permissions: permissions)
        }

        for path in childPaths.other {
            try path.change(permissions: permissions)
        }

        for directory in childPaths.directories {
            try directory.changeRecursive(permissions: permissions)
        }

        try change(permissions: permissions)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - owner: The permissions for the owner of the path
        - group: The permissions for members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

    - Throws: `ChangePermissionsError.permissionDenied` when the calling process does not have the proper permissions to modify path permissions
    - Throws: `ChangePermissionsError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `ChangePermissionsError.ioError` when an I/O error occurred during the API call
    - Throws: `ChangePermissionsError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `ChangePermissionsError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangePermissionsError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangePermissionsError.noKernelMemory` when there is insufficient memory to change the path's permissions
    - Throws: `ChangePermissionsError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangePermissionsError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func changeRecursive(owner: FilePermissions, group: FilePermissions, others: FilePermissions, bits: FileBits, options: DirectoryEnumerationOptions = .includeHidden) throws {
        try changeRecursive(permissions: FileMode(owner: owner, group: group, others: others, bits: bits), options: options)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - owner: The permissions for the owner of the path
        - group: The permissions for members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

    - Throws: `ChangePermissionsError.permissionDenied` when the calling process does not have the proper permissions to modify path permissions
    - Throws: `ChangePermissionsError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `ChangePermissionsError.ioError` when an I/O error occurred during the API call
    - Throws: `ChangePermissionsError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `ChangePermissionsError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangePermissionsError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangePermissionsError.noKernelMemory` when there is insufficient memory to change the path's permissions
    - Throws: `ChangePermissionsError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangePermissionsError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func changeRecursive(owner: FilePermissions? = nil, group: FilePermissions? = nil, others: FilePermissions? = nil, bits: FileBits? = nil, options: DirectoryEnumerationOptions = .includeHidden) throws {
        let current = permissions
        try changeRecursive(owner: owner ?? current.owner, group: group ?? current.group, others: others ?? current.others, bits: bits ?? current.bits, options: options)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - ownerGroup: The permissions for the path owner and also members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

    - Throws: `ChangePermissionsError.permissionDenied` when the calling process does not have the proper permissions to modify path permissions
    - Throws: `ChangePermissionsError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `ChangePermissionsError.ioError` when an I/O error occurred during the API call
    - Throws: `ChangePermissionsError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `ChangePermissionsError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangePermissionsError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangePermissionsError.noKernelMemory` when there is insufficient memory to change the path's permissions
    - Throws: `ChangePermissionsError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangePermissionsError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func changeRecursive(ownerGroup perms: FilePermissions, others: FilePermissions? = nil, bits: FileBits? = nil, options: DirectoryEnumerationOptions = .includeHidden) throws {
        let current = permissions
        try changeRecursive(owner: perms, group: perms, others: current.others, bits: bits ?? current.bits, options: options)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - ownerOthers: The permissions for the owner of the path and everyone else
        - group: The permissions for members of the group with access to the path
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

    - Throws: `ChangePermissionsError.permissionDenied` when the calling process does not have the proper permissions to modify path permissions
    - Throws: `ChangePermissionsError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `ChangePermissionsError.ioError` when an I/O error occurred during the API call
    - Throws: `ChangePermissionsError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `ChangePermissionsError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangePermissionsError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangePermissionsError.noKernelMemory` when there is insufficient memory to change the path's permissions
    - Throws: `ChangePermissionsError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangePermissionsError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func changeRecursive(ownerOthers perms: FilePermissions, group: FilePermissions? = nil, bits: FileBits? = nil, options: DirectoryEnumerationOptions = .includeHidden) throws {
        let current = permissions
        try changeRecursive(owner: perms, group: group ?? current.group, others: perms, bits: bits ?? current.bits, options: options)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - groupOthers: The permissions for members of the group with access to the path and anyone else
        - owner: The permissions for the owner of the path
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

    - Throws: `ChangePermissionsError.permissionDenied` when the calling process does not have the proper permissions to modify path permissions
    - Throws: `ChangePermissionsError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `ChangePermissionsError.ioError` when an I/O error occurred during the API call
    - Throws: `ChangePermissionsError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `ChangePermissionsError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangePermissionsError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangePermissionsError.noKernelMemory` when there is insufficient memory to change the path's permissions
    - Throws: `ChangePermissionsError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangePermissionsError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func changeRecursive(groupOthers perms: FilePermissions, owner: FilePermissions? = nil, bits: FileBits? = nil, options: DirectoryEnumerationOptions = .includeHidden) throws {
        let current = permissions
        try changeRecursive(owner: owner ?? current.owner, group: perms, others: perms, bits: bits ?? current.bits, options: options)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - ownerGroupOthers: The permissions for the owner of the path, members of the group, and everyone else
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

    - Throws: `ChangePermissionsError.permissionDenied` when the calling process does not have the proper permissions to modify path permissions
    - Throws: `ChangePermissionsError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `ChangePermissionsError.ioError` when an I/O error occurred during the API call
    - Throws: `ChangePermissionsError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `ChangePermissionsError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangePermissionsError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangePermissionsError.noKernelMemory` when there is insufficient memory to change the path's permissions
    - Throws: `ChangePermissionsError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangePermissionsError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func changeRecursive(ownerGroupOthers perms: FilePermissions, bits: FileBits? = nil, options: DirectoryEnumerationOptions = .includeHidden) throws {
        try changeRecursive(owner: perms, group: perms, others: perms, bits: bits ?? permissions.bits, options: options)
    }

    /**
    Appends a String to a DirectoryPath

    - Parameter lhs: The DirectoryPath to append to
    - Parameter rhs: The String to append

    - Returns: A GenericPath which is the combination of the lhs + Path.separator + rhs
    */
    public static func + (lhs: DirectoryPath, rhs: String) -> GenericPath {
        return lhs + GenericPath(rhs)
    }

    /**
    Appends a Path to a DirectoryPath

    - Parameter lhs: The DirectoryPath to append to
    - Parameter rhs: The Path to append

    - Returns: A PathType which is the combination of the lhs + Path.separator + rhs
    */
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

        return PathType(newPath) !! "Failed to instantiate \(PathType.self) from \(Swift.type(of: newPath)) '\(newPath)'"
    }

    /**
    Append a DirectoryPath to another

    - Parameter lhs: The DirectoryPath to modify
    - Parameter rhs: The DirectoryPath to append
    */
    public static func += (lhs: inout DirectoryPath, rhs: DirectoryPath) {
        lhs = lhs + rhs
    }

    @available(*, unavailable, message: "Appending FilePath to DirectoryPath results in a FilePath, but it is impossible to change the type of the left-hand object from a DirectoryPath to a FilePath")
    public static func += (lhs: inout DirectoryPath, rhs: FilePath) {}

    // Be sure to close any open directories during deconstruction
    deinit {
        try? close()
    }
}
