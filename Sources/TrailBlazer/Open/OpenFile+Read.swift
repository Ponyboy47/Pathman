import Foundation
import ErrNo

#if os(Linux)
import Glibc
/// The C function to read from an open file descriptor
private let cReadFile = Glibc.read
#else
import Darwin
/// The C function to read from an open file descriptor
private let cReadFile = Darwin.read
#endif

/// Protocol declaration of types that can be read from
public protocol Readable: Opened {
    func read(bytes bytesToRead: ByteRepresentable) throws -> Data
}

extension Readable {
    /**
     Read a path and return a string of the data read

     - Parameter bytesToRead: The number of bytes to read in the file
     - Parameter encoding: The encoding used to store data in the file
     - Returns: A String of the data read from the file

     - Throws: `ReadError.wouldBlock` when the file was opened with the `.nonBlock` flag and the read operation would block
     - Throws: `ReadError.badFileDescriptor` when the underlying file descriptor is invalid or not opened
     - Throws: `ReadError.badBufferAddress` when the buffer points to a location outside you accessible address space
     - Throws: `ReadError.interruptedBySignal` when the API call was interrupted by a signal handler
     - Throws: `ReadError.cannotReadFileDescriptor` when the underlying file descriptor is attached to a path which is unsuitable for reading or the file was opened with the `.direct` flag and either the buffer addres, the byteCount, or the offset are not suitably aligned
     - Throws: `ReadError.ioError` when an I/O error occured during the API call
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
     */
    public func read(bytes bytesToRead: ByteRepresentable = Int.max, encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead), encoding: encoding)
    }
}

extension Readable where Self: Seekable {
    /**
     Read data from a path

     - Parameter offset: Where to begin reading data from within the file
     - Parameter bytesToRead: The number of bytes to read from the file
     - Returns: The Data read from the file

     - Throws: `ReadError.wouldBlock` when the file was opened with the `.nonBlock` flag and the read operation would block
     - Throws: `ReadError.badFileDescriptor` when the underlying file descriptor is invalid or not opened
     - Throws: `ReadError.badBufferAddress` when the buffer points to a location outside you accessible address space
     - Throws: `ReadError.interruptedBySignal` when the API call was interrupted by a signal handler
     - Throws: `ReadError.cannotReadFileDescriptor` when the underlying file descriptor is attached to a path which is unsuitable for reading or the file was opened with the `.direct` flag and either the buffer addres, the byteCount, or the offset are not suitably aligned
     - Throws: `ReadError.ioError` when an I/O error occured during the API call
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
     */
    public func read(from offset: Offset, bytes bytesToRead: ByteRepresentable = Int.max) throws -> Data {
        try seek(offset)
        return try read(bytes: bytesToRead)
    }

    /**
    Read a path and return a string of the data read

    - Parameter offset: Where to begin reading from in the file
    - Parameter bytesToRead: The number of bytes to read in the file
    - Parameter encoding: The encoding used to store data in the file
    - Returns: A String of the data read from the file

    - Throws: `ReadError.wouldBlock` when the file was opened with the `.nonBlock` flag and the read operation would block
    - Throws: `ReadError.badFileDescriptor` when the underlying file descriptor is invalid or not opened
    - Throws: `ReadError.badBufferAddress` when the buffer points to a location outside you accessible address space
    - Throws: `ReadError.interruptedBySignal` when the API call was interrupted by a signal handler
    - Throws: `ReadError.cannotReadFileDescriptor` when the underlying file descriptor is attached to a path which is unsuitable for reading or the file was opened with the `.direct` flag and either the buffer addres, the byteCount, or the offset are not suitably aligned
    - Throws: `ReadError.ioError` when an I/O error occured during the API call
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
    */
    public func read(from offset: Offset, bytes bytesToRead: ByteRepresentable = Int.max, encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead), encoding: encoding)
    }
}

/// Contains the buffer used for reading from a path
private var _buffers: [Int: UnsafeMutablePointer<CChar>] = [:]
/// Tracks the sizes of the read buffers
private var _bufferSizes: [Int: Int] = [:]

extension Open: Readable where PathType == FilePath {
    /// The buffer used to store data read from a path
    var buffer: UnsafeMutablePointer<CChar>? {
        get {
            return _buffers[hashValue]
        }
        set {
            guard let newBuffer = newValue else {
                if let bSize = bufferSize {
                    _buffers[hashValue]?.deinitialize(count: bSize)
                    _buffers[hashValue]?.deallocate()
                }
                _buffers.removeValue(forKey: hashValue)
                return
            }
            _buffers[hashValue] = newBuffer
        }
    }
    /// The size of the buffer used to store read data
    var bufferSize: Int? {
        get {
            return _bufferSizes[hashValue]
        }
        set {
            guard let newSize = newValue else {
                _bufferSizes.removeValue(forKey: hashValue)
                return
            }
            // Deinitializes and deallocates any existing memory
            buffer = nil

            buffer = UnsafeMutablePointer<CChar>.allocate(capacity: newSize)
            _bufferSizes[hashValue] = newSize
        }
    }

    /**
    Read data from a path

    - Parameter offset: Where to begin reading data from within the file
    - Parameter bytesToRead: The number of bytes to read from the file
    - Returns: The Data read from the file

    - Throws: `ReadError.wouldBlock` when the file was opened with the `.nonBlock` flag and the read operation would block
    - Throws: `ReadError.badFileDescriptor` when the underlying file descriptor is invalid or not opened
    - Throws: `ReadError.badBufferAddress` when the buffer points to a location outside you accessible address space
    - Throws: `ReadError.interruptedBySignal` when the API call was interrupted by a signal handler
    - Throws: `ReadError.cannotReadFileDescriptor` when the underlying file descriptor is attached to a path which is unsuitable for reading or the file was opened with the `.direct` flag and either the buffer addres, the byteCount, or the offset are not suitably aligned
    - Throws: `ReadError.ioError` when an I/O error occured during the API call
    */
    public func read(bytes sizeToRead: ByteRepresentable = Int.max) throws -> Data {
        guard mayRead else {
            throw ReadError.cannotReadFileDescriptor
        }
        let bytes = sizeToRead.bytes

        let bytesToRead = bytes > size ? Int(size) : bytes

        // If we haven't allocated a buffer before, then allocate one now
        if buffer == nil {
            bufferSize = bytesToRead
        // If the buffer size is less than bytes we're going to read then reallocate the buffer
        } else if let bSize = bufferSize, bSize < bytesToRead {
            bufferSize = bytesToRead
        }

        // Reading the file returns the number of bytes read (or -1 if there was an error)
        let bytesRead = cReadFile(fileDescriptor, buffer!, bytesToRead)
        guard bytesRead != -1 else { throw ReadError.getError() }

        // Return the Data read from the file
        return Data(bytes: buffer!, count: bytesRead)
    }
}

public extension FilePath {
    /**
    Opens a file and reads data from it

    - Parameter offset: Where to begin reading data from within the file
    - Parameter bytesToRead: The number of bytes to read from the file
    - Returns: The Data read from the file

    - Throws: `ReadError.wouldBlock` when the file was opened with the `.nonBlock` flag and the read operation would block
    - Throws: `ReadError.badFileDescriptor` when the underlying file descriptor is invalid or not opened
    - Throws: `ReadError.badBufferAddress` when the buffer points to a location outside you accessible address space
    - Throws: `ReadError.interruptedBySignal` when the API call was interrupted by a signal handler
    - Throws: `ReadError.cannotReadFileDescriptor` when the underlying file descriptor is attached to a path which is unsuitable for reading or the file was opened with the `.direct` flag and either the buffer addres, the byteCount, or the offset are not suitably aligned
    - Throws: `ReadError.ioError` when an I/O error occured during the API call
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
    public func read(from offset: Offset = .current, bytes bytesToRead: ByteRepresentable = Int.max) throws -> Data {
        return try open(permissions: .read).read(from: offset, bytes: bytesToRead)
    }

    /**
    Opens a file, reads it, and returns a string of the data read

    - Parameter offset: Where to begin reading from in the file
    - Parameter bytesToRead: The number of bytes to read in the file
    - Parameter encoding: The encoding used to store data in the file
    - Returns: A String of the data read from the file

    - Throws: `ReadError.wouldBlock` when the file was opened with the `.nonBlock` flag and the read operation would block
    - Throws: `ReadError.badFileDescriptor` when the underlying file descriptor is invalid or not opened
    - Throws: `ReadError.badBufferAddress` when the buffer points to a location outside you accessible address space
    - Throws: `ReadError.interruptedBySignal` when the API call was interrupted by a signal handler
    - Throws: `ReadError.cannotReadFileDescriptor` when the underlying file descriptor is attached to a path which is unsuitable for reading or the file was opened with the `.direct` flag and either the buffer addres, the byteCount, or the offset are not suitably aligned
    - Throws: `ReadError.ioError` when an I/O error occured during the API call
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
    public func read(from offset: Offset = .current, bytes bytesToRead: ByteRepresentable = Int.max, encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead), encoding: encoding)
    }
}
