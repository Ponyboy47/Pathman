#if os(Linux)
import Glibc
/// The C function that opens a file
private let cOpenFile = Glibc.open(_:_:)
/// The C function that opens a file with the mode argument
private let cOpenFileWithMode = Glibc.open(_:_:_:)
/// The C function that closes an open file descriptor
private let cCloseFile = Glibc.close
#else
import Darwin
/// The C function that opens a file
private let cOpenFile = Darwin.open(_:_:)
/// The C function that opens a file with the mode argument
private let cOpenFileWithMode = Darwin.open(_:_:_:)
/// The C function that closes an open file descriptor
private let cCloseFile = Darwin.close
#endif

/// A Path to a file
open class FilePath: Path, Openable, Linkable {
    public typealias OpenableType = FilePath
    public typealias OpenOptionsType = OpenOptions

    public var _path: String
    public internal(set) var fileDescriptor: FileDescriptor? {
        didSet {
            if fileDescriptor != nil {
                opened = OpenFile(self)
            } else {
                opened = nil
            }
        }
    }
    public internal(set) var openOptions: OpenOptionsType?
    private var _tmpOpenOptions: OpenOptionsType?

    public var opened: OpenFile?

    public var openPermissions: OpenFilePermissions { return openOptions?.permissions ?? .none }
    public var openFlags: OpenFileFlags { return openOptions?.flags ?? .none }
    public var createMode: FileMode? { return openOptions?.mode }

    public var mayRead: Bool { return openPermissions.mayRead }
    public var mayWrite: Bool { return openPermissions.mayWrite }

    // This is to protect the info from being set externally
    private var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /// Initialize from an array of path elements
    public required init?(_ components: [String]) {
        _path = components.filter({ !$0.isEmpty && $0 != FilePath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == FilePath.separator {
            _path = first + _path
        }
        _info = StatInfo(_path)

        if exists {
            guard isFile else { return nil }
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
        if str.count > 1 && str.hasSuffix(FilePath.separator) {
            _path = String(str.dropLast())
        } else {
            _path = str
        }
        _info = StatInfo(_path)

        if exists {
            guard isFile else { return nil }
        }
    }

    /**
    Initialize from another FilePath (copy constructor)

    - Parameter  path: The path to copy
    */
    public required init(_ path: FilePath) {
        _path = path._path
        _info = path.info
    }

    /**
    Initialize from GenericPath

    If the path is a directory then this initializer fails

    - Parameter path: The path to copy
    */
    public required init?(_ path: GenericPath) {
        // Cannot initialize a file from a non-file type
        if path.exists {
            guard path.isFile else { return nil }
        }

        _path = path._path
        _info = path.info
    }

    @available(*, unavailable, message: "Cannot append to a FilePath")
    public static func + <PathType: Path>(lhs: FilePath, rhs: PathType) -> PathType { fatalError("Cannot append to a FilePath") }


    /**
    Opens the file

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
    @discardableResult
    open func open() throws -> Open<FilePath> {
        let options = try (_tmpOpenOptions ?? openOptions) ?! OpenFileError.invalidPermissions

        guard options.permissions != .none else { throw OpenFileError.invalidPermissions }

        if let opened = opened {
            if options == openOptions
               || (openOptions!.permissions.contains(options.permissions)
                  && options.flags.contains(openOptions!.flags))
            { return opened }
            try close()
        }

        let rawOptions = options.permissions.rawValue | options.flags.rawValue

        if let mode = options.mode {
            fileDescriptor = cOpenFileWithMode(string, rawOptions, mode.rawValue)
        } else {
            guard !options.flags.contains(.create) else {
                throw OpenFileError.createWithoutMode
            }
            fileDescriptor = cOpenFile(string, rawOptions)
        }

        guard fileDescriptor != -1 else { throw OpenFileError.getError() }

        defer {
            self.openOptions = options
            self._tmpOpenOptions = nil
        }
        return opened !! "Failed to set the opened file object"
    }

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
    @discardableResult
    open func open(permissions: OpenFilePermissions, flags: OpenFileFlags = [], mode: FileMode? = nil) throws -> Open<FilePath> {
        _tmpOpenOptions = OpenOptions(permissions: permissions, flags: flags, mode: mode)
        return try open()
    }

    /**
    Closes the file (if previously opened)

    - Throws: `CloseFileError.badFileDescriptor` when the underlying file descriptor being closed is already closed or is not a valid file descriptor
    - Throws: `CloseFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `CloseFileError.ioError` when an I/O error occurred
    */
    open func close() throws {
        // File is not open
        guard let fileDescriptor = fileDescriptor else { return }

        // deinitializes and deallocates any existing memory
        opened?.buffer = nil
        opened?.bufferSize = nil

        // Remove the open file from the openFiles dict after we close it
        defer {
            openOptions = nil
            self.fileDescriptor = nil
        }

        guard cCloseFile(fileDescriptor) == 0 else {
            throw CloseFileError.getError()
        }
    }

    // Be sure to close any open files on deconstruction
    deinit {
        try? close()
    }
}

extension FilePath {
    public struct OpenOptions: Hashable {
        public let permissions: OpenFilePermissions
        public let flags: OpenFileFlags
        public let mode: FileMode?

        public init(permissions: OpenFilePermissions, flags: OpenFileFlags = [], mode: FileMode? = nil) {
            self.permissions = permissions
            self.flags = flags
            self.mode = mode
        }
    }
}
