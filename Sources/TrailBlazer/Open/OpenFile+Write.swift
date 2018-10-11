import Foundation
#if os(Linux)
import Glibc
private let cWriteFile = Glibc.write
#else
import Darwin
private let cWriteFile = Darwin.write
#endif

/// Protocol declaration of types that can be written to
public protocol Writable: Openable, Seekable {
    /// Seeks to the specified offset and writes the specified bytes
    func write(_ buffer: Data, at offset: Offset) throws
    /// Seeks to the specified offset and write the specified String
    func write(_ string: String, at offset: Offset, using encoding: String.Encoding) throws
}

public extension Writable {
    /**
    Seeks to the specified offset and writes the string

    - Parameter string: The string to write to the path
    - Parameter offset: The offset to seek to before writing to the path
    - Parameter encoding: The string encoding to use when writing to the path

    - Throws: `WriteError.wouldBlock` when the path was opened with the `.nonBlock` flag but the write operation would block
    - Throws: `WriteError.quotaReached` when the user's quota of disk blocks for the path have been exhausted
    - Throws: `WriteError.fileTooLarge` when an ettempt was made to write a file that exceeds the maximum defined file size for either the system or the process, or to write at a position past the maximum allowed offset
    - Throws: `WriteError.interruptedBySignal` when the API call was interrupted by a signal handler before any data was written
    - Throws: `WriteError.cannotWriteToFileDescriptor` when the underlying file descriptor is attached to a path which is unsuitable for writing or the file was opened with the `.direct` flag and either the buffer address, the byteCount, or the offset are not suitably aligned
    - Throws: `WriteError.ioError` when an I/O error occurred during the API call
    - Throws: `WriteError.fileSystemFull` when the file system is full
    - Throws: `WriteError.permissionDenied` when the operation was prevented because of a file seal (see fcntl(2))
    */
    public func write(_ string: String, at offset: Offset = .current, using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, at: offset)
    }
}

extension Open: Writable where PathType: FilePath {
    /**
    Seeks to the specified offset and writes the data

    - Parameter buffer: The data to write to the path
    - Parameter offset: The offset to seek to before writing to the path

    - Throws: `WriteError.wouldBlock` when the path was opened with the `.nonBlock` flag but the write operation would block
    - Throws: `WriteError.quotaReached` when the user's quota of disk blocks for the path have been exhausted
    - Throws: `WriteError.fileTooLarge` when an ettempt was made to write a file that exceeds the maximum defined file size for either the system or the process, or to write at a position past the maximum allowed offset
    - Throws: `WriteError.interruptedBySignal` when the API call was interrupted by a signal handler before any data was written
    - Throws: `WriteError.cannotWriteToFileDescriptor` when the underlying file descriptor is attached to a path which is unsuitable for writing or the file was opened with the `.direct` flag and either the buffer address, the byteCount, or the offset are not suitably aligned
    - Throws: `WriteError.ioError` when an I/O error occurred during the API call
    - Throws: `WriteError.fileSystemFull` when the file system is full
    - Throws: `WriteError.permissionDenied` when the operation was prevented because of a file seal (see fcntl(2))
    */
    public func write(_ buffer: Data, at offset: Offset = .current) throws {
        if !mayWrite {
            try path.open(permissions: .write)
        }

        if !openFlags.contains(.append) {
            try seek(offset)
        }

        guard cWriteFile(fileDescriptor, [UInt8](buffer), buffer.count) != -1 else { throw WriteError.getError() }
    }
}

public extension FilePath {
    /**
    Opens the file, seeks to the specified offset, and writes the data

    - Parameter buffer: The data to write to the path
    - Parameter offset: The offset to seek to before writing to the path

    - Throws: `WriteError.wouldBlock` when the path was opened with the `.nonBlock` flag but the write operation would block
    - Throws: `WriteError.quotaReached` when the user's quota of disk blocks for the path have been exhausted
    - Throws: `WriteError.fileTooLarge` when an ettempt was made to write a file that exceeds the maximum defined file size for either the system or the process, or to write at a position past the maximum allowed offset
    - Throws: `WriteError.interruptedBySignal` when the API call was interrupted by a signal handler before any data was written
    - Throws: `WriteError.cannotWriteToFileDescriptor` when the underlying file descriptor is attached to a path which is unsuitable for writing or the file was opened with the `.direct` flag and either the buffer address, the byteCount, or the offset are not suitably aligned
    - Throws: `WriteError.ioError` when an I/O error occurred during the API call
    - Throws: `WriteError.fileSystemFull` when the file system is full
    - Throws: `WriteError.permissionDenied` when the operation was prevented because of a file seal (see fcntl(2))
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
    */
    public func write(_ buffer: Data, at offset: Offset = .current) throws {
        let openFile = try open(permissions: .write)
        defer { try? openFile.close() }
        try openFile.write(buffer, at: offset)
    }

    /**
    Seeks to the specified offset and writes the string

    - Parameter string: The string to write to the path
    - Parameter offset: The offset to seek to before writing to the path
    - Parameter encoding: The string encoding to use when writing to the path

    - Throws: `WriteError.wouldBlock` when the path was opened with the `.nonBlock` flag but the write operation would block
    - Throws: `WriteError.quotaReached` when the user's quota of disk blocks for the path have been exhausted
    - Throws: `WriteError.fileTooLarge` when an ettempt was made to write a file that exceeds the maximum defined file size for either the system or the process, or to write at a position past the maximum allowed offset
    - Throws: `WriteError.interruptedBySignal` when the API call was interrupted by a signal handler before any data was written
    - Throws: `WriteError.cannotWriteToFileDescriptor` when the underlying file descriptor is attached to a path which is unsuitable for writing or the file was opened with the `.direct` flag and either the buffer address, the byteCount, or the offset are not suitably aligned
    - Throws: `WriteError.ioError` when an I/O error occurred during the API call
    - Throws: `WriteError.fileSystemFull` when the file system is full
    - Throws: `WriteError.permissionDenied` when the operation was prevented because of a file seal (see fcntl(2))
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
    */
    public func write(_ string: String, at offset: Offset = .current, using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, at: offset)
    }
}
