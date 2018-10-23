#if os(Linux)
import Glibc
let cLink = Glibc.link
let cSymlink = Glibc.symlink
let cUnlink = Glibc.unlink
let cReadlink = Glibc.readlink
#else
import Darwin
let cLink = Darwin.link
let cSymlink = Darwin.symlink
let cUnlink = Darwin.unlink
let cReadlink = Darwin.readlink
#endif

public enum LinkType {
    case hard
    case symbolic
    public static let soft: LinkType = .symbolic
}

public var defaultLinkType: LinkType = .symbolic

extension Path {
    public func link(at linkedPath: Self, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        return try LinkedPath(linkedPath, linkedTo: self, type: type)
    }

    public func link(at linkedString: String, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        guard let linkedPath = Self(linkedString) else { throw LinkError.pathTypeMismatch }
        return try self.link(at: linkedPath, type: type)
    }

    public func link(from targetPath: Self, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        return try LinkedPath(self, linkedTo: targetPath, type: type)
    }

    public func link(from targetString: String, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        guard let targetPath = Self(targetString) else { throw LinkError.pathTypeMismatch }
        return try link(from: targetPath, type: type)
    }
}

public struct LinkedPath<LinkedPathType: Path>: Path {
    public static var pathType: PathType { return .link }

    public var _path: String {
        get { return __path._path }
        set { __path._path = newValue }
    }
    private var __path: LinkedPathType

    public let _info: StatInfo

    public private(set) var link: LinkedPathType
    public private(set) var linkType: LinkType

    public let isLink: Bool = true

    public var isDangling: Bool {
        // If the path we're linked to exists then the link is not dangling.
        // Hard links cannot be dangling.
        return linkType == .hard ? false : link.exists.toggled()
    }

    public init(_ path: String, linkedTo linkPath: LinkedPathType, type: LinkType = TrailBlazer.defaultLinkType) throws {
        let pathLink = try LinkedPathType.init(path) ?! LinkError.pathTypeMismatch
        try self.init(pathLink, linkedTo: linkPath, type: type)
    }

    public init(_ pathLink: LinkedPathType, linkedTo link: String, type: LinkType = TrailBlazer.defaultLinkType) throws {
        let linkPath = try LinkedPathType.init(link) ?! LinkError.pathTypeMismatch
        try self.init(pathLink, linkedTo: linkPath, type: type)
    }

    public init(_ path: String, linkedTo link: String, type: LinkType = TrailBlazer.defaultLinkType) throws {
        let pathLink = try LinkedPathType.init(path) ?! LinkError.pathTypeMismatch
        let linkPath = try LinkedPathType.init(link) ?! LinkError.pathTypeMismatch
        try self.init(pathLink, linkedTo: linkPath, type: type)
    }

    public mutating func unlink() throws {
        guard cUnlink(_path) != -1 else { throw UnlinkError.getError() }
    }

    public init(_ pathLink: LinkedPathType, linkedTo linkPath: LinkedPathType, type: LinkType = TrailBlazer.defaultLinkType) throws {
        __path = LinkedPathType(pathLink)
        _info = StatInfo(pathLink.string)

        try createLink(from: pathLink, to: linkPath, type: type)
        self.link = linkPath
        linkType = type
    }

    /// Initialize a symbolic link from an array of Path components
    public init?(_ components: [String]) {
        guard let path = LinkedPathType(components) else { return nil }
        __path = path
        _info = StatInfo(path.string)
        try? _info.getInfo()

        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(PATH_MAX) + 1)
        defer {
            buffer.deinitialize(count: Int(PATH_MAX) + 1)
            buffer.deallocate()
        }

        let linkSize = cReadlink(path.string, buffer, Int(PATH_MAX))
        guard linkSize != -1 else { return nil }

        // realink(2) does not null-terminate the string stored in the buffer,
        // Swift expects it to be null-terminated to convert a cString to a Swift String
        buffer[linkSize] = 0
        guard let link = LinkedPathType.init(String(cString: buffer)) else { return nil }

        self.link = link
        linkType = .symbolic
    }

    /// Initialize a symbolic link from an array of Path components
    public init?(_ str: String) {
        guard let path = LinkedPathType(str) else { return nil }
        __path = path
        _info = StatInfo(path.string)
        try? _info.getInfo()

        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(PATH_MAX) + 1)
        defer {
            buffer.deinitialize(count: Int(PATH_MAX) + 1)
            buffer.deallocate()
        }

        let linkSize = cReadlink(path.string, buffer, Int(PATH_MAX))
        guard linkSize != -1 else { return nil }

        // realink(2) does not null-terminate the string stored in the buffer,
        // Swift expects it to be null-terminated to convert a cString to a Swift String
        buffer[linkSize] = 0
        guard let link = LinkedPathType.init(String(cString: buffer)) else { return nil }

        self.link = link
        linkType = .symbolic
    }

    public init(_ path: LinkedPath<LinkedPathType>) {
        __path = LinkedPathType(path.__path)
        _info = StatInfo(path.string)
        try? _info.getInfo()
        link = path.link
        linkType = path.linkType
    }

    /// Initialize a symbolic link from an array of Path components
    public init?(_ path: GenericPath) {
        guard let _path = LinkedPathType(path) else { return nil }
        __path = _path
        _info = StatInfo(_path.string)
        try? _info.getInfo()

        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(PATH_MAX) + 1)
        defer {
            buffer.deinitialize(count: Int(PATH_MAX) + 1)
            buffer.deallocate()
        }

        let linkSize = cReadlink(_path.string, buffer, Int(PATH_MAX))
        guard linkSize != -1 else { return nil }

        // realink(2) does not null-terminate the string stored in the buffer,
        // Swift expects it to be null-terminated to convert a cString to a Swift String
        buffer[linkSize] = 0
        guard let link = LinkedPathType.init(String(cString: buffer)) else { return nil }

        self.link = link
        linkType = .symbolic
    }

    public mutating func delete() throws {
        try unlink()
    }
}

extension LinkedPath: DirectoryEnumerable where LinkedPathType: DirectoryEnumerable {
    public func children(options: DirectoryEnumerationOptions = []) throws -> PathCollection {
        return try __path.children(options: options)
    }
}

extension LinkedPath where LinkedPathType: Openable {
    public func open(options: LinkedPathType.OpenOptionsType) throws -> Open<LinkedPathType> {
        return try __path.open(options: options)
    }

    public func open(options: LinkedPathType.OpenOptionsType, closure: (_ opened: Open<LinkedPathType>) throws -> ()) throws {
        try closure(open(options: options))
    }
}

extension LinkedPath where LinkedPathType: Openable, LinkedPathType.OpenOptionsType == Empty {
    public func open() throws -> Open<LinkedPathType> {
        return try open(options: .default)
    }

    public func open(closure: (_ opened: Open<LinkedPathType>) throws -> ()) throws {
        try closure(open())
    }
}

extension LinkedPath where LinkedPathType == FilePath {
    /**
    Opens the file

    - Parameters:
        - permissions: The permissions to be used with the open file. (`.read`, `.write`, or `.readWrite`)
        - flags: The flags with which to open the file
        - mode: The permissions to use if creating a file
    - Returns: The opened file

    - Throws: `OpenFileError.permissionDenied` when write access is not allowed to the path or if search permissions were denied on one of the components of the path
    - Throws: `OpenFileError.quotaReached` when the file does not exist and the user's quota of disk blocks or inodes on the filesystem has been exhausted
    - Throws: `OpenFileError.pathExists` when creating a path that already exists
    - Throws: `OpenFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `OpenFileError.fileTooLarge` when the path is a file that is too large to be opened. Generally occurs on a 32-bit platform when opening a file whose size is larger than a 32-bit integer
    - Throws: `OpenFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `OpenFileError.invalidFlags` when an invalid value is specified in the `options`. May also mean the `.direct` flag was used and this system does not support it
    - Throws: `OpenFileError.shouldNotFollowSymlinks` when the `.noFollow` flag was used and a symlink was discovered to be part of the path's components
    - Throws: `OpenFileError.tooManySymlinks` when too many symlinks were encountered while resolving the path name
    - Throws: `OpenFileError.noProcessFileDescriptors` when the calling process has no more available file descriptors
    - Throws: `OpenFileError.noSystemFileDescriptors` when the entire system has no more available file descriptors
    - Throws: `OpenFileError.pathnameTooLong` when the path exceeds `PATH_MAX` number of characters
    - Throws: `OpenFileError.noDevice` when the path points to a special file and no corresponding device exists
    - Throws: `OpenFileError.noRouteToPath` when the path cannot be resolved
    - Throws: `OpenFileError.noKernelMemory` when there is no memory available
    - Throws: `OpenFileError.fileSystemFull` when there is no available disk space
    - Throws: `OpenFileError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `OpenFileError.readOnlyFileSystem` when the filesystem is in read only mode
    - Throws: `OpenFileError.pathBusy` when the path is an executable image which is currently being executed
    - Throws: `OpenFileError.wouldBlock` when the `.nonBlock` flag was used and an incompatible lease is held on the file (see fcntl(2))
    - Throws: `OpenFileError.createWithoutMode` when creating a path and the mode is nil
    - Throws: `OpenFileError.lockedDevice` when the device where path exists is locked from writing
    - Throws: `OpenFileError.ioErrorCreatingPath` (macOS only) when an I/O error occurred while creating the inode for the path
    - Throws: `OpenFileError.operationNotSupported` (macOS only) when the `.sharedLock` or `.exclusiveLock` flags were specified and the underlying filesystem doesn't support locking or the path is a socket and opening a socket is not supported yet
    - Throws: `CloseFileError.badFileDescriptor` when the underlying file descriptor being closed is already closed or is not a valid file descriptor
    - Throws: `CloseFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `CloseFileError.ioError` when an I/O error occurred

    - Warning: Beware opening the same file multiple times with non-overlapping options/permissions. In order to reduce the number of open file descriptors, a single file can only be opened once at a time. If you open the same path with different permissions or flags, then the previously opened instance will be closed before the new one is opened. ie: if youre going to use a path for reading and writing, then open it using the `.readWrite` permissions rather than first opening it with `.read` and then later opening it with `.write`
    - Note: A `CloseFileError` will only be thrown if the file has previously been opened and is now being reopened with non-overlapping `options` as the previous open. So we first will close the old open file and then open it with the new options
    */
    public func open(permissions: OpenFilePermissions, flags: OpenFileFlags = [], mode: FileMode? = nil) throws -> Open<LinkedPathType> {
        return try open(options: FilePath.OpenOptions(permissions: permissions, flags: flags, mode: mode))
    }

    /**
    Opens the file and runs the closure with the opened file

    - Parameters:
        - permissions: The permissions to be used with the open file. (`.read`, `.write`, or `.readWrite`)
        - flags: The flags with which to open the file
        - mode: The permissions to use if creating a file
        - closue: The closure to run with the opened file

    - Throws: `OpenFileError.permissionDenied` when write access is not allowed to the path or if search permissions were denied on one of the components of the path
    - Throws: `OpenFileError.quotaReached` when the file does not exist and the user's quota of disk blocks or inodes on the filesystem has been exhausted
    - Throws: `OpenFileError.pathExists` when creating a path that already exists
    - Throws: `OpenFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `OpenFileError.fileTooLarge` when the path is a file that is too large to be opened. Generally occurs on a 32-bit platform when opening a file whose size is larger than a 32-bit integer
    - Throws: `OpenFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `OpenFileError.invalidFlags` when an invalid value is specified in the `options`. May also mean the `.direct` flag was used and this system does not support it
    - Throws: `OpenFileError.shouldNotFollowSymlinks` when the `.noFollow` flag was used and a symlink was discovered to be part of the path's components
    - Throws: `OpenFileError.tooManySymlinks` when too many symlinks were encountered while resolving the path name
    - Throws: `OpenFileError.noProcessFileDescriptors` when the calling process has no more available file descriptors
    - Throws: `OpenFileError.noSystemFileDescriptors` when the entire system has no more available file descriptors
    - Throws: `OpenFileError.pathnameTooLong` when the path exceeds `PATH_MAX` number of characters
    - Throws: `OpenFileError.noDevice` when the path points to a special file and no corresponding device exists
    - Throws: `OpenFileError.noRouteToPath` when the path cannot be resolved
    - Throws: `OpenFileError.noKernelMemory` when there is no memory available
    - Throws: `OpenFileError.fileSystemFull` when there is no available disk space
    - Throws: `OpenFileError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `OpenFileError.readOnlyFileSystem` when the filesystem is in read only mode
    - Throws: `OpenFileError.pathBusy` when the path is an executable image which is currently being executed
    - Throws: `OpenFileError.wouldBlock` when the `.nonBlock` flag was used and an incompatible lease is held on the file (see fcntl(2))
    - Throws: `OpenFileError.createWithoutMode` when creating a path and the mode is nil
    - Throws: `OpenFileError.lockedDevice` when the device where path exists is locked from writing
    - Throws: `OpenFileError.ioErrorCreatingPath` (macOS only) when an I/O error occurred while creating the inode for the path
    - Throws: `OpenFileError.operationNotSupported` (macOS only) when the `.sharedLock` or `.exclusiveLock` flags were specified and the underlying filesystem doesn't support locking or the path is a socket and opening a socket is not supported yet
    - Throws: `CloseFileError.badFileDescriptor` when the underlying file descriptor being closed is already closed or is not a valid file descriptor
    - Throws: `CloseFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `CloseFileError.ioError` when an I/O error occurred

    - Warning: Beware opening the same file multiple times with non-overlapping options/permissions. In order to reduce the number of open file descriptors, a single file can only be opened once at a time. If you open the same path with different permissions or flags, then the previously opened instance will be closed before the new one is opened. ie: if youre going to use a path for reading and writing, then open it using the `.readWrite` permissions rather than first opening it with `.read` and then later opening it with `.write`
    - Note: A `CloseFileError` will only be thrown if the file has previously been opened and is now being reopened with non-overlapping `options` as the previous open. So we first will close the old open file and then open it with the new options
    */
    public func open(permissions: OpenFilePermissions, flags: OpenFileFlags = [], mode: FileMode? = nil, closure: (_ opened: Open<LinkedPathType>) throws -> ()) throws {
        try open(options: FilePath.OpenOptions(permissions: permissions, flags: flags, mode: mode), closure: closure)
    }
}

private func createLink<PathType: Path>(from: PathType, to: PathType, type: LinkType) throws {
    switch type {
    case .hard:
        guard cLink(to.string, from.string) != -1 else { throw LinkError.getError() }
    case .soft, .symbolic:
        guard cSymlink(to.string, from.string) != -1 else { throw SymlinkError.getError() }
    }
}
