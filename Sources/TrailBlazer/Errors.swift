import ErrNo
import Cglob

public protocol TrailBlazerError: Error {
    static func getError() -> Self
}

// Creating files uses the open(2) call so it's errors are the same
public typealias CreateFileError = OpenFileError

public enum OpenFileError: TrailBlazerError {
    case unknown
    case permissionDenied
    case quotaReached
    case pathExists
    case badAddress
    case fileTooLarge
    case interruptedBySignal
    case invalidFlags
    case improperUseOfDirectory
    case shouldNotFollowSymlinks
    case tooManySymlinks
    case noMoreProcessFileDescriptors
    case noMoreSystemFileDescriptors
    case pathnameTooLong
    case noDevice
    case noRouteToPath
    case noKernelMemory
    case fileSystemFull
    case pathComponentNotDirectory
    case deviceNotOpened
    case noTempFS
    case readOnlyFileSystem
    case deviceBusy
    case wouldBlock
    case createWithoutMode
    case invalidOrEmptyPermissions
    #if os(macOS)
    case lockedDevice
    case ioErrorCreatingPath
    case operationNotSupported
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
        case .EISDIR: return .improperUseOfDirectory
        case .ELOOP:
            if flags.contains(.noFollow) {
                return .shouldNotFollowSymlinks
            } else {
                return .tooManySymlinks
            }
        case .EMFILE: return .noMoreProcessFileDescriptors
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENFILE: return .noMoreSystemFileDescriptors
        case .ENODEV: return .noDevice
        case .ENOENT: return .noRouteToPath
        case .ENOMEM: return .noKernelMemory
        case .ENOSPC: return .fileSystemFull
        case .ENOTDIR: return .pathComponentNotDirectory
        case .ENXIO: return .deviceNotOpened
        case .EOPNOTSUPP: return .noTempFS
        case .EOVERFLOW: return .fileTooLarge
        case .EPERM: return .permissionDenied
        case .EROFS: return .readOnlyFileSystem
        case .ETXTBSY: return .deviceBusy
        case .EWOULDBLOCK: return .wouldBlock
        #if os(macOS)
        case .EAGAIN: return .lockedDevice
        case .EIO: return .ioErrorCreatingPath
        case .EOPNOTSUPP: return .operationNotSupported
        #endif
        default: return .unknown
        }
    }
}

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

public enum DeleteFileError: TrailBlazerError {
    case unknown
    case permissionDenied
    case fileInUse
    case badAddress
    case ioError
    case isDirectory
    case tooManySymlinks
    case pathnameTooLong
    case noRouteToPath
    case pathComponentNotDirectory
    case noKernelMemory
    case readOnlyFileSystem

    public static func getError() -> DeleteFileError {
        switch ErrNo.lastError {
        case .EACCES, .EPERM: return .permissionDenied
        case .EBUSY: return .fileInUse
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

public enum DupError: TrailBlazerError {
    case unknown
    case unopenedFileDescriptor
    case interruptedBySignal
    case noMoreProcessFileDescriptors

    public static func getError() -> DupError {
        switch ErrNo.lastError {
        case .EBADF: return .unopenedFileDescriptor
        case .EINTR: return .interruptedBySignal
        case .EMFILE: return .noMoreProcessFileDescriptors
        default: return .unknown
        }
    }
}

public enum OpenDirectoryError: TrailBlazerError {
    case unknown
    case permissionDenied
    case badFileDescriptor
    case noMoreProcessFileDescriptors
    case noMoreSystemFileDescriptors
    case pathDoesNotExist
    case outOfMemory
    case pathComponentNotDirectory

    public static func getError() -> OpenDirectoryError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EBADF: return .badFileDescriptor
        case .EMFILE: return .noMoreProcessFileDescriptors
        case .ENFILE: return .noMoreSystemFileDescriptors
        case .ENOENT: return .pathDoesNotExist
        case .ENOMEM: return .outOfMemory
        case .ENOTDIR: return .pathComponentNotDirectory
        default: return .unknown
        }
    }
}

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

public enum PathError: TrailBlazerError {
    case unknown
    case permissionDenied
    case emptyPath
    case ioError
    case tooManySymlinks
    case pathnameTooLong
    case outOfMemory
    case pathDoesNotExist
    case pathComponentNotDirectory

    public static func getError() -> PathError {
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

public enum UserInfoError: TrailBlazerError {
    case unknown
    case userDoesNotExist
    case interruptedBySignal
    case ioError
    case noMoreProcessFileDescriptors
    case noMoreSystemFileDescriptors
    case outOfMemory
    case invalidHomeDirectory

    public static func getError() -> UserInfoError {
        switch ErrNo.lastError {
        case 0, .ENOENT, .ESRCH, .EBADF, .EPERM: return .userDoesNotExist
        case .EINTR: return .interruptedBySignal
        case .EIO: return .ioError
        case .EMFILE: return .noMoreProcessFileDescriptors
        case .ENFILE: return .noMoreSystemFileDescriptors
        case .ENOMEM: return .outOfMemory
        default: return .unknown
        }
    }
}

public enum GroupInfoError: TrailBlazerError {
    case unknown
    case userDoesNotExist
    case interruptedBySignal
    case ioError
    case noMoreProcessFileDescriptors
    case noMoreSystemFileDescriptors
    case outOfMemory

    public static func getError() -> GroupInfoError {
        switch ErrNo.lastError {
        case 0, .ENOENT, .ESRCH, .EBADF, .EPERM: return .userDoesNotExist
        case .EINTR: return .interruptedBySignal
        case .EIO: return .ioError
        case .EMFILE: return .noMoreProcessFileDescriptors
        case .ENFILE: return .noMoreSystemFileDescriptors
        case .ENOMEM: return .outOfMemory
        default: return .unknown
        }
    }
}

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

public enum SeekError: TrailBlazerError {
    case unknown
    case unknownOffsetType
    case fileDescriptorIsNotOpen
    case invalidOffset
    case offsetTooLarge
    case fileDescriptorIsNotFile
    #if os(macOS)
    case noMoreData
    #endif

    public static func getError() -> SeekError {
        switch ErrNo.lastError {
        case .EBADF: return .fileDescriptorIsNotOpen
        case .EINVAL, .ENXIO: return .invalidOffset
        case .EOVERFLOW: return .offsetTooLarge
        case .ESPIPE: return .fileDescriptorIsNotFile
        #if os(macOS)
        case .ENXIO: return .noMoreData
        #endif
        default: return .unknown
        }
    }
}

public enum RealPathError: TrailBlazerError {
    case unknown
    case permissionDenied
    case emptyPath
    case ioError
    case tooManySymlinks
    case pathnameTooLong
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

public enum StringError: TrailBlazerError {
    case unknown
    case notConvertibleToData(using: String.Encoding)

    public static func getError() -> StringError {
        return .unknown
    }
}

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
