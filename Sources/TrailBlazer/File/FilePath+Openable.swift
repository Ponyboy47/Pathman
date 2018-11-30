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

extension FilePath: Openable {
    public typealias OpenOptionsType = OpenOptions

    public struct OpenOptions: DefaultReadableWritableOpenOption {
        public let permissions: OpenFilePermissions
        public let flags: OpenFileFlags
        public let mode: FileMode?

        public static let readableDefault = OpenOptions(permissions: .read)
        public static let writableDefault = OpenOptions(permissions: .write)
        public static let readableWritableDefault = OpenOptions(permissions: .readWrite)

        public init(permissions: OpenFilePermissions, flags: OpenFileFlags = [], mode: FileMode? = nil) {
            self.permissions = permissions
            self.flags = flags
            self.mode = mode
        }
    }

    /**
    Opens the file

    - Returns: The opened file

    - Throws: `OpenFileError.permissionDenied` when write access is not allowed to the path or if search permissions
               were denied on one of the components of the path
    - Throws: `OpenFileError.quotaReached` when the file does not exist and the user's quota of disk blocks or inodes on
               the filesystem has been exhausted
    - Throws: `OpenFileError.pathExists` when creating a path that already exists
    - Throws: `OpenFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `OpenFileError.fileTooLarge` when the path is a file that is too large to be opened. Generally occurs on a
               32-bit platform when opening a file whose size is larger than a 32-bit integer
    - Throws: `OpenFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `OpenFileError.invalidFlags` when an invalid value is specified in the `options`. May also mean the
               `.direct` flag was used and this system does not support it
    - Throws: `OpenFileError.shouldNotFollowSymlinks` when the `.noFollow` flag was used and a symlink was discovered to
               be part of the path's components
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
    - Throws: `OpenFileError.wouldBlock` when the `.nonBlock` flag was used and an incompatible lease is held on the
               file (see fcntl(2))
    - Throws: `OpenFileError.createWithoutMode` when creating a path and the mode is nil
    - Throws: `OpenFileError.lockedDevice` when the device where path exists is locked from writing
    - Throws: `OpenFileError.ioErrorCreatingPath` (macOS only) when an I/O error occurred while creating the inode for
               the path
    - Throws: `OpenFileError.operationNotSupported` (macOS only) when the `.sharedLock` or `.exclusiveLock` flags were
               specified and the underlying filesystem doesn't support locking or the path is a socket and opening a
               socket is not supported yet
    - Throws: `CloseFileError.badFileDescriptor` when the underlying file descriptor being closed is already closed or
               is not a valid file descriptor
    - Throws: `CloseFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `CloseFileError.ioError` when an I/O error occurred
    */
    public func open(options: OpenOptions) throws -> Open<FilePath> {
        guard options.permissions != .none else { throw OpenFileError.invalidPermissions }

        let rawOptions = options.permissions.rawValue | options.flags.rawValue

        let fileDescriptor: FileDescriptor
        if let mode = options.mode {
            fileDescriptor = cOpenFileWithMode(string, rawOptions, mode.rawValue)
        } else if options.flags.contains(.create) {
            throw CreateFileError.createWithoutMode
        } else {
            fileDescriptor = cOpenFile(string, rawOptions)
        }

        guard fileDescriptor != -1 else { throw OpenFileError.getError() }

        return OpenFile(self, descriptor: fileDescriptor, options: options) !! "Failed to set the opened file object"
    }

    /**
    Opens the file

    - Parameters:
        - permissions: The permissions to be used with the open file. (`.read`, `.write`, or `.readWrite`)
        - flags: The flags with which to open the file
        - mode: The permissions to use if creating a file
    - Returns: The opened file

    - Throws: `OpenFileError.permissionDenied` when write access is not allowed to the path or if search permissions
               were denied on one of the components of the path
    - Throws: `OpenFileError.quotaReached` when the file does not exist and the user's quota of disk blocks or inodes on
               the filesystem has been exhausted
    - Throws: `OpenFileError.pathExists` when creating a path that already exists
    - Throws: `OpenFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `OpenFileError.fileTooLarge` when the path is a file that is too large to be opened. Generally occurs on a
               32-bit platform when opening a file whose size is larger than a 32-bit integer
    - Throws: `OpenFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `OpenFileError.invalidFlags` when an invalid value is specified in the `options`. May also mean the
               `.direct` flag was used and this system does not support it
    - Throws: `OpenFileError.shouldNotFollowSymlinks` when the `.noFollow` flag was used and a symlink was discovered to
               be part of the path's components
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
    - Throws: `OpenFileError.wouldBlock` when the `.nonBlock` flag was used and an incompatible lease is held on the
               file (see fcntl(2))
    - Throws: `OpenFileError.createWithoutMode` when creating a path and the mode is nil
    - Throws: `OpenFileError.lockedDevice` when the device where path exists is locked from writing
    - Throws: `OpenFileError.ioErrorCreatingPath` (macOS only) when an I/O error occurred while creating the inode for
               the path
    - Throws: `OpenFileError.operationNotSupported` (macOS only) when the `.sharedLock` or `.exclusiveLock` flags were
               specified and the underlying filesystem doesn't support locking or the path is a socket and opening a
               socket is not supported yet
    - Throws: `CloseFileError.badFileDescriptor` when the underlying file descriptor being closed is already closed or
               is not a valid file descriptor
    - Throws: `CloseFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `CloseFileError.ioError` when an I/O error occurred
    */
    public func open(permissions: OpenFilePermissions,
                     flags: OpenFileFlags = [],
                     mode: FileMode? = nil) throws -> Open<FilePath> {
        return try open(options: OpenOptions(permissions: permissions, flags: flags, mode: mode))
    }

    /**
    Opens the file and runs the closure with the opened file

    - Parameters:
        - permissions: The permissions to be used with the open file. (`.read`, `.write`, or `.readWrite`)
        - flags: The flags with which to open the file
        - mode: The permissions to use if creating a file
        - closue: The closure to run with the opened file

    - Throws: `OpenFileError.permissionDenied` when write access is not allowed to the path or if search permissions
               were denied on one of the components of the path
    - Throws: `OpenFileError.quotaReached` when the file does not exist and the user's quota of disk blocks or inodes on
               the filesystem has been exhausted
    - Throws: `OpenFileError.pathExists` when creating a path that already exists
    - Throws: `OpenFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `OpenFileError.fileTooLarge` when the path is a file that is too large to be opened. Generally occurs on a
               32-bit platform when opening a file whose size is larger than a 32-bit integer
    - Throws: `OpenFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `OpenFileError.invalidFlags` when an invalid value is specified in the `options`. May also mean the
               `.direct` flag was used and this system does not support it
    - Throws: `OpenFileError.shouldNotFollowSymlinks` when the `.noFollow` flag was used and a symlink was discovered to
               be part of the path's components
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
    - Throws: `OpenFileError.wouldBlock` when the `.nonBlock` flag was used and an incompatible lease is held on the
               file (see fcntl(2))
    - Throws: `OpenFileError.createWithoutMode` when creating a path and the mode is nil
    - Throws: `OpenFileError.lockedDevice` when the device where path exists is locked from writing
    - Throws: `OpenFileError.ioErrorCreatingPath` (macOS only) when an I/O error occurred while creating the inode for
               the path
    - Throws: `OpenFileError.operationNotSupported` (macOS only) when the `.sharedLock` or `.exclusiveLock` flags were
               specified and the underlying filesystem doesn't support locking or the path is a socket and opening a
               socket is not supported yet
    - Throws: `CloseFileError.badFileDescriptor` when the underlying file descriptor being closed is already closed or
               is not a valid file descriptor
    - Throws: `CloseFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `CloseFileError.ioError` when an I/O error occurred
    */
    public func open(permissions: OpenFilePermissions,
                     flags: OpenFileFlags = [],
                     mode: FileMode? = nil,
                     closure: (_ opened: Open<FilePath>) throws -> Void) throws {
        try open(options: OpenOptions(permissions: permissions, flags: flags, mode: mode), closure: closure)
    }

    /**
    Closes the file (if previously opened)

    - Throws: `CloseFileError.badFileDescriptor` when the underlying file descriptor being closed is already closed or
               is not a valid file descriptor
    - Throws: `CloseFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `CloseFileError.ioError` when an I/O error occurred
    */
    public static func close(opened: Open<FilePath>) throws {
        // File is not open
        guard opened.descriptor != -1 else { return }

        guard cCloseFile(opened.descriptor) == 0 else {
            throw CloseFileError.getError()
        }

        opened.path.buffer = nil
        opened.path.bufferSize = nil
    }
}