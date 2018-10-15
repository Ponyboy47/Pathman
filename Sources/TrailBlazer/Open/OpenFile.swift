#if os(Linux)
import Glibc
#else
import Darwin
#endif

public typealias OpenFile = Open<FilePath>

extension Open where PathType == FilePath {
    /// Whether or not the path was opened with read permissions
    public var mayRead: Bool {
        return openPermissions.mayRead
    }

    /// Whether or not the path was opened with write permissions
    public var mayWrite: Bool {
        return openPermissions.mayWrite
    }

    public var openPermissions: OpenFilePermissions { return openOptions.permissions }
    public var openFlags: OpenFileFlags { return openOptions.flags }
    public var createMode: FileMode? { return openOptions.mode }

    /**
     Reopens the file with the newly specified permissions

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
    public func open(permissions: OpenFilePermissions, flags: OpenFileFlags = [], mode: FileMode? = nil) throws -> Open<FilePath> {
        return try path.open(permissions: permissions, flags: flags, mode: mode)
    }
}
