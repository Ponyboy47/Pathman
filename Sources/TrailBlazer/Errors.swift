import ErrNo
import Cglob

/// The Error type used by anything that throws in this library
public protocol TrailBlazerError: Error {
    /// A function used to return the Error based on the ErrNo
    static func getError() -> Self
}

// Creating files uses the open(2) call so it's errors are the same
/// Errors thrown when a FilePath is created (see open(2))
public typealias CreateFileError = OpenFileError

/// Errors thrown when a FilePath is opened (see open(2))
public enum OpenFileError: TrailBlazerError {
    case unknown
    case permissionDenied
    case quotaReached
    case pathExists
    case badAddress
    case fileTooLarge
    case interruptedBySignal
    case invalidPermissions
    case invalidFlags
    // case improperUseOfDirectory
    case shouldNotFollowSymlinks
    case tooManySymlinks
    case noProcessFileDescriptors
    case noSystemFileDescriptors
    case pathnameTooLong
    case noDevice
    case noRouteToPath
    case noKernelMemory
    case fileSystemFull
    case pathComponentNotDirectory
    case deviceNotOpened
    case readOnlyFileSystem
    case pathBusy
    case wouldBlock
    case createWithoutMode
    case operationNotSupported
    #if os(macOS)
    case lockedDevice
    case ioErrorCreatingPath
    #endif

    public static func getError() -> OpenFileError {
        return .getError(flags: [])
    }

    public static func getError(flags: OpenFileFlags) -> OpenFileError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EDQUOT: return .quotaReached
        case .EEXIST: return .pathExists
        case .EFAULT: return .badAddress
        case .EFBIG: return .fileTooLarge
        case .EINTR: return .interruptedBySignal
        case .EINVAL: return .invalidFlags
        // This should only occur when opening a directory and since this is
        // restricted to opening files it _shouldn't_ ever occur
        // case .EISDIR: return .improperUseOfDirectory
        case .ELOOP:
            if flags.contains(.noFollow) {
                return .shouldNotFollowSymlinks
            } else {
                return .tooManySymlinks
            }
        case .EMFILE: return .noProcessFileDescriptors
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENFILE: return .noSystemFileDescriptors
        case .ENODEV: return .noDevice
        case .ENOENT: return .noRouteToPath
        case .ENOMEM: return .noKernelMemory
        case .ENOSPC: return .fileSystemFull
        case .ENOTDIR: return .pathComponentNotDirectory
        case .ENXIO: return .deviceNotOpened
        case .EOVERFLOW: return .fileTooLarge
        case .EPERM: return .permissionDenied
        case .EROFS: return .readOnlyFileSystem
        case .ETXTBSY: return .pathBusy
        case .EWOULDBLOCK: return .wouldBlock
        case .EOPNOTSUPP: return .operationNotSupported
        #if os(macOS)
        case .EAGAIN: return .lockedDevice
        case .EIO: return .ioErrorCreatingPath
        #endif
        default: return .unknown
        }
    }
}

/// Errors thrown when a FilePath is closed (see close(2))
public enum CloseFileError: TrailBlazerError {
    case unknown
    case badFileDescriptor
    case interruptedBySignal
    case ioError

    public static func getError() -> CloseFileError {
        switch ErrNo.lastError {
        case .EBADF: return .badFileDescriptor
        case .EINTR: return .interruptedBySignal
        case .EIO: return .ioError
        default: return .unknown
        }
    }
}

/// Errors thrown when a FilePath is deleted
public typealias DeleteFileError = UnlinkError

/// Errors thrown when a path is unlinked (see unlink(2))
public enum UnlinkError: TrailBlazerError {
    case unknown
    case permissionDenied
    case pathInUse
    case badAddress
    case ioError
    case isDirectory
    case tooManySymlinks
    case pathnameTooLong
    case noRouteToPath
    case pathComponentNotDirectory
    case noKernelMemory
    case readOnlyFileSystem

    public static func getError() -> UnlinkError {
        switch ErrNo.lastError {
        case .EACCES, .EPERM: return .permissionDenied
        case .EBUSY: return .pathInUse
        case .EFAULT: return .badAddress
        case .EIO: return .ioError
        case .EISDIR: return .isDirectory
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .noRouteToPath
        case .ENOTDIR: return .pathComponentNotDirectory
        case .ENOMEM: return .noKernelMemory
        case .EROFS: return .readOnlyFileSystem
        default: return .unknown
        }
    }
}

/// Errors thrown when a path is linked (see link(2))
public enum LinkError: TrailBlazerError {
    case unknown
    case noLinkType
    case pathTypeMismatch
    case permissionDenied
    case quotaReached
    case alreadyExists
    case badAddress
    case ioError
    case tooManySymlinks
    case linkLimitReached
    case pathnameTooLong
    case noRouteToPath
    case noKernelMemory
    case deviceFull
    case pathComponentNotDirectory
    case operationNotSupported
    case readOnlyFileSystem
    case pathsOnDifferentFileSystems

    public static func getError() -> LinkError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EDQUOT: return .quotaReached
        case .EEXIST: return .alreadyExists
        case .EFAULT: return .badAddress
        case .EIO: return .ioError
        case .ELOOP: return .tooManySymlinks
        case .EMLINK: return .linkLimitReached
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .noRouteToPath
        case .ENOMEM: return .noKernelMemory
        case .ENOSPC: return .deviceFull
        case .ENOTDIR: return .pathComponentNotDirectory
        case .EPERM: return .operationNotSupported
        case .EROFS: return .readOnlyFileSystem
        case .EXDEV: return .pathsOnDifferentFileSystems
        default: return .unknown
        }
    }
}

/// Errors thrown when a path is symlinked (see symlink(2))
public enum SymlinkError: TrailBlazerError {
    case unknown
    case permissionDenied
    case quotaReached
    case alreadyExists
    case badAddress
    case ioError
    case tooManySymlinks
    case pathnameTooLong
    case noRouteToPath
    case noKernelMemory
    case deviceFull
    case pathComponentNotDirectory
    case operationNotSupported
    case readOnlyFileSystem

    public static func getError() -> SymlinkError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EDQUOT: return .quotaReached
        case .EEXIST: return .alreadyExists
        case .EFAULT: return .badAddress
        case .EIO: return .ioError
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .noRouteToPath
        case .ENOMEM: return .noKernelMemory
        case .ENOSPC: return .deviceFull
        case .ENOTDIR: return .pathComponentNotDirectory
        case .EPERM: return .operationNotSupported
        case .EROFS: return .readOnlyFileSystem
        default: return .unknown
        }
    }
}

/// Errors thrown when a DirectoryPath is opened (see opendir(3))
public enum OpenDirectoryError: TrailBlazerError {
    case unknown
    case permissionDenied
    // case badFileDescriptor
    case noProcessFileDescriptors
    case noSystemFileDescriptors
    case pathDoesNotExist
    case outOfMemory
    case pathNotDirectory

    public static func getError() -> OpenDirectoryError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        // This would only occur for the fopendir(2) C API call, which is not being used
        // case .EBADF: return .badFileDescriptor
        case .EMFILE: return .noProcessFileDescriptors
        case .ENFILE: return .noSystemFileDescriptors
        case .ENOENT: return .pathDoesNotExist
        case .ENOMEM: return .outOfMemory
        case .ENOTDIR: return .pathNotDirectory
        default: return .unknown
        }
    }
}

/// Errors thrown when a DirectoryPath is closed (see closedir(3))
public enum CloseDirectoryError: TrailBlazerError {
    case unknown
    case invalidDirectoryStream

    public static func getError() -> CloseDirectoryError {
        switch ErrNo.lastError {
        case .EBADF: return .invalidDirectoryStream
        default: return .unknown
        }
    }
}

/// Thrown when a path is set to be deleted (via a recursiveDelete of a DirectoryPath) and it is not a deletable path
public enum GenericDeleteError: Error {
    case cannotDeleteGenericPath(GenericPath)
}

/// Errors thrown when a DirectoryPath is created (see mkdir(2))
public enum CreateDirectoryError: TrailBlazerError {
    case unknown
    case permissionDenied
    case quotaReached
    case pathExists
    case badAddress
    case tooManySymlinks
    case pathnameTooLong
    case noRouteToPath
    case noKernelMemory
    case fileSystemFull
    case pathComponentNotDirectory
    case readOnlyFileSystem
    #if os(macOS)
    case ioError
    case pathIsRootDirectory
    #endif

    public static func getError() -> CreateDirectoryError {
        switch ErrNo.lastError {
        case .EACCES, .EPERM: return .permissionDenied
        case .EDQUOT: return .quotaReached
        case .EEXIST: return .pathExists
        case .EFAULT: return .badAddress
        case .ELOOP, .EMLINK: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .noRouteToPath
        case .ENOMEM: return .noKernelMemory
        case .ENOSPC: return .fileSystemFull
        case .ENOTDIR: return .pathComponentNotDirectory
        case .EROFS: return .readOnlyFileSystem
        #if os(macOS)
        case .EIO: return .ioError
        case .EISDIR: return .pathIsRootDirectory
        #endif
        default: return .unknown
        }
    }
}

/// Errors thrown when a DirectoryPath is deleted (see rmdir(2))
public enum DeleteDirectoryError: TrailBlazerError {
    case unknown
    case permissionDenied
    case directoryInUse
    case badAddress
    case relativePath
    case tooManySymlinks
    case pathnameTooLong
    case noRouteToPath
    case pathComponentNotDirectory
    case noKernelMemory
    case directoryNotEmpty
    case readOnlyFileSystem
    #if os(macOS)
    case ioError
    #endif

    public static func getError() -> DeleteDirectoryError {
        switch ErrNo.lastError {
        case .EACCES, .EPERM: return .permissionDenied
        case .EBUSY: return .directoryInUse
        case .EFAULT: return .badAddress
        case .EINVAL: return .relativePath
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .noRouteToPath
        case .ENOTDIR: return .pathComponentNotDirectory
        case .ENOMEM: return .noKernelMemory
        case .ENOTEMPTY: return .directoryNotEmpty
        case .EROFS: return .readOnlyFileSystem
        #if os(macOS)
        case .EIO: return .ioError
        #endif
        default: return .unknown
        }
    }
}

/// Errors thrown getting path information (see stat(2))
public enum StatError: TrailBlazerError {
    case unknown
    case permissionDenied
    case badFileDescriptor
    case badAddress
    case tooManySymlinks
    case pathnameTooLong
    case noRouteToPath
    case outOfMemory
    case pathComponentNotDirectory
    case fileTooLarge
    #if os(macOS)
    case ioError
    #endif

    public static func getError() -> StatError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EBADF: return .badFileDescriptor
        case .EFAULT: return .badAddress
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .noRouteToPath
        case .ENOMEM: return .outOfMemory
        case .ENOTDIR: return .pathComponentNotDirectory
        case .EOVERFLOW: return .fileTooLarge
        #if os(macOS)
        case .EIO: return .ioError
        #endif
        default: return .unknown
        }
    }
}

/// Errors thrown while getting information about a user (see getpwnam(2) or getpwuid(2))
public enum UserInfoError: TrailBlazerError {
    case unknown
    case userDoesNotExist
    case interruptedBySignal
    case ioError
    case noProcessFileDescriptors
    case noSystemFileDescriptors
    case outOfMemory
    case invalidHomeDirectory

    public static func getError() -> UserInfoError {
        switch ErrNo.lastError {
        case 0, .ENOENT, .ESRCH, .EBADF, .EPERM: return .userDoesNotExist
        case .EINTR: return .interruptedBySignal
        case .EIO: return .ioError
        case .EMFILE: return .noProcessFileDescriptors
        case .ENFILE: return .noSystemFileDescriptors
        case .ENOMEM: return .outOfMemory
        default: return .unknown
        }
    }
}

/// Errors thrown while getting information about a group (see getgrnam(2) or getgrgid(2))
public enum GroupInfoError: TrailBlazerError {
    case unknown
    case userDoesNotExist
    case interruptedBySignal
    case ioError
    case noProcessFileDescriptors
    case noSystemFileDescriptors
    case outOfMemory

    public static func getError() -> GroupInfoError {
        switch ErrNo.lastError {
        case 0, .ENOENT, .ESRCH, .EBADF, .EPERM: return .userDoesNotExist
        case .EINTR: return .interruptedBySignal
        case .EIO: return .ioError
        case .EMFILE: return .noProcessFileDescriptors
        case .ENFILE: return .noSystemFileDescriptors
        case .ENOMEM: return .outOfMemory
        default: return .unknown
        }
    }
}

/// Errors thrown by trying to read a fileDescriptor (see read(2))
public enum ReadError: TrailBlazerError {
    case unknown
    case wouldBlock
    case badFileDescriptor
    case badBufferAddress
    case interruptedBySignal
    case cannotReadFileDescriptor
    case ioError
    case isDirectory
    #if os(macOS)
    case bufferAllocationFailed
    case deviceError
    case connectionReset
    case notConnected
    case timeout
    #endif

    public static func getError() -> ReadError {
        switch ErrNo.lastError {
        case .EAGAIN, .EWOULDBLOCK: return .wouldBlock
        case .EBADF: return .badFileDescriptor
        case .EFAULT: return .badBufferAddress
        case .EINTR: return .interruptedBySignal
        case .EINVAL: return .cannotReadFileDescriptor
        case .EIO: return .ioError
        case .EISDIR: return .isDirectory
        #if os(macOS)
        case .ENOBUFS: return .bufferAllocationFailed
        case .ENXIO: return .deviceError
        case .ECONNRESET: return .connectionReset
        case .ENOTCONN: return .notConnected
        case .ETIMEDOUT: return .timeout
        #endif
        default: return .unknown
        }
    }
}

/// Errors thrown by trying to seek to an offset for a fileDescriptor (see seek(2))
public enum SeekError: TrailBlazerError {
    case unknown
    case unknownOffsetType
    case fileDescriptorIsNotOpen
    case invalidOffset
    case offsetTooLarge
    case fileDescriptorIsNotFile
    #if SEEK_DATA && SEEK_HOLE
    case noData
    #endif

    public static func getError() -> SeekError {
        switch ErrNo.lastError {
        case .EBADF: return .fileDescriptorIsNotOpen
        case .EINVAL: return .invalidOffset
        case .EOVERFLOW: return .offsetTooLarge
        case .ESPIPE: return .fileDescriptorIsNotFile
        #if SEEK_DATA && SEEK_HOLE
        case .ENXIO: return .noData
        #endif
        default: return .unknown
        }
    }
}

/// Errors thrown while expanding relative paths or symlinks (see realpath(3))
public enum RealPathError: TrailBlazerError {
    case unknown
    case permissionDenied
    case emptyPath
    case ioError
    case tooManySymlinks
    case pathnameTooLong
    case pathComponentTooLong
    case outOfMemory
    case pathDoesNotExist
    case pathComponentNotDirectory

    public static func getError() -> RealPathError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EINVAL: return .emptyPath
        case .EIO: return .ioError
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOMEM: return .outOfMemory
        case .ENOENT: return .pathDoesNotExist
        case .ENOTDIR: return .pathComponentNotDirectory
        default: return .unknown
        }
    }
}

/// Errors thrown during String conversions from Data
public enum StringError: TrailBlazerError {
    case unknown
    case notConvertibleToData(using: String.Encoding)

    public static func getError() -> StringError {
        return .unknown
    }
}

/// Errors thrown by trying to write to a fileDescriptor (see write(2))
public enum WriteError: TrailBlazerError {
    case unknown
    case wouldBlock
    case badFileDescriptor
    case unconnectedSocket
    case quotaReached
    case badBufferAddress
    case fileTooLarge
    case interruptedBySignal
    case cannotWriteToFileDescriptor
    case ioError
    case fileSystemFull
    case permissionDenied
    case pipeOrSocketClosed
    #if os(macOS)
    case notConnected
    case networkDown
    case networkUnreachable
    case deviceError
    #endif

    public static func getError() -> WriteError {
        switch ErrNo.lastError {
        case .EAGAIN, .EWOULDBLOCK: return .wouldBlock
        case .EBADF: return .badFileDescriptor
        case .EDESTADDRREQ: return .unconnectedSocket
        case .EDQUOT: return .quotaReached
        case .EFAULT: return .badBufferAddress
        case .EFBIG: return .fileTooLarge
        case .EINTR: return .interruptedBySignal
        case .EINVAL: return .cannotWriteToFileDescriptor
        case .EIO: return .ioError
        case .ENOSPC: return .fileSystemFull
        case .EPERM: return .permissionDenied
        case .EPIPE: return .pipeOrSocketClosed
        #if os(macOS)
        case .ECONNRESET: return .notConnected
        case .ENETDOWN: return .networkDown
        case .ENETUNREACH: return .networkUnreachable
        case .ENXIO: return .deviceError
        #endif
        default: return .unknown
        }
    }
}

/// Errors thrown while changing Path ownership (see chown(2))
public enum ChangeOwnershipError: TrailBlazerError {
    case unknown
    case permissionDenied
    case badAddress
    case tooManySymlinks
    case pathnameTooLong
    case pathDoesNotExist
    case noKernelMemory
    case pathComponentNotDirectory
    case readOnlyFileSystem
    case badFileDescriptor
    case ioError

    public static func getError() -> ChangeOwnershipError {
        switch ErrNo.lastError {
        case .EACCES, .EPERM: return .permissionDenied
        case .EFAULT: return .badAddress
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .pathDoesNotExist
        case .ENOMEM: return .noKernelMemory
        case .ENOTDIR: return .pathComponentNotDirectory
        case .EROFS: return .readOnlyFileSystem
        case .EBADF: return .badFileDescriptor
        case .EIO: return .ioError
        default: return .unknown
        }
    }
}

/// Errors thrown while changing the permissions on a Path (see chmod(2))
public enum ChangePermissionsError: TrailBlazerError {
    case unknown
    case permissionDenied
    case badAddress
    case ioError
    case tooManySymlinks
    case pathnameTooLong
    case pathDoesNotExist
    case noKernelMemory
    case pathComponentNotDirectory
    case readOnlyFileSystem
    case badFileDescriptor

    public static func getError() -> ChangePermissionsError {
        switch ErrNo.lastError {
        case .EACCES, .EPERM: return .permissionDenied
        case .EFAULT: return .badAddress
        case .EIO: return .ioError
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .pathDoesNotExist
        case .ENOMEM: return .noKernelMemory
        case .ENOTDIR: return .pathComponentNotDirectory
        case .EROFS: return .readOnlyFileSystem
        case .EBADF: return .badFileDescriptor
        default: return .unknown
        }
    }
}

/// Errors thrown by moving or renaming a Path (see rename(2))
public enum MoveError: TrailBlazerError {
    case unknown
    case permissionDenied
    case pathInUse
    case quotaReached
    case badAddress
    case invalidNewPath
    case newPathIsDirectory_OldPathIsNot
    case tooManySymlinks
    case symlinkLimitReached
    case pathnameTooLong
    case pathDoesNotExist
    case noKernelMemory
    case fileSystemFull
    case pathComponentNotDirectory
    case newPathIsNonEmptyDirectory
    case readOnlyFileSystem
    case pathsOnDifferentFileSystems
    case moveToDifferentPathType

    public static func getError() -> MoveError {
        switch ErrNo.lastError {
        case .EACCES, .EPERM: return .permissionDenied
        case .EBUSY: return .pathInUse
        case .EDQUOT: return .quotaReached
        case .EFAULT: return .badAddress
        case .EINVAL: return .invalidNewPath
        case .EISDIR: return .newPathIsDirectory_OldPathIsNot
        case .ELOOP: return .tooManySymlinks
        case .EMLINK: return .symlinkLimitReached
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .pathDoesNotExist
        case .ENOMEM: return .noKernelMemory
        case .ENOSPC: return .fileSystemFull
        case .ENOTDIR: return .pathComponentNotDirectory
        case .ENOTEMPTY, .EEXIST: return .newPathIsNonEmptyDirectory
        case .EROFS: return .readOnlyFileSystem
        case .EXDEV: return .pathsOnDifferentFileSystems
        default: return .unknown
        }
    }
}

/// Errors thrown by globbing (see glob(3))
public enum GlobError: TrailBlazerError {
    public typealias ErrorHandler = (@convention(c) (UnsafePointer<CChar>?, OptionInt) -> OptionInt)
    case unknown
    case outOfMemory
    case readError
    case noMatches

    public static func getError() -> GlobError {
        return .unknown
    }
    public static func getError(_ returnVal: OptionInt) -> GlobError {
        if returnVal == GLOB_NOSPACE {
            return .outOfMemory
        } else if returnVal == GLOB_ABORTED {
            return .readError
        } else if returnVal == GLOB_NOMATCH {
            return .noMatches
        }

        return .unknown
    }
}

/// Errors thrown by creating/opening a temporary file/directory (see mkstemp(3)/mkdtemp(3))
public enum MakeTemporaryError: TrailBlazerError {
    case unknown
    case alreadyExists

    public static func getError() -> MakeTemporaryError {
        switch ErrNo.lastError {
        case .EEXIST: return .alreadyExists
        default: return .unknown
        }
    }
}

public enum CodingError: Error {
    case incorrectPathType(String)
}

public enum CopyError: Error {
    case uncopyablePath(GenericPath)
    case nonEmptyDirectory
}
