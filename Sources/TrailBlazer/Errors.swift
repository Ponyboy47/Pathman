import ErrNo

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
    case segFault
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
    case notDirectory
    case deviceNotOpened
    case noTempFS
    case readOnlyFileSystem
    case deviceBusy
    case wouldBlock
    case createWithoutMode
    case invalidOrEmptyPermissions

    public static func getError() -> OpenFileError {
		return .getError(flags: [])
    }

	public static func getError(flags: OpenFileFlags) -> OpenFileError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EDQUOT: return .quotaReached
        case .EEXIST: return .pathExists
        case .EFAULT: return .segFault
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
        case .ENOTDIR: return .notDirectory
        case .ENXIO: return .deviceNotOpened
        case .EOPNOTSUPP: return .noTempFS
        case .EOVERFLOW: return .fileTooLarge
        case .EPERM: return .permissionDenied
        case .EROFS: return .readOnlyFileSystem
        case .ETXTBSY: return .deviceBusy
        case .EWOULDBLOCK: return .wouldBlock
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
        case .ENOENT, .ENOTDIR: return .noRouteToPath
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
    case notDirectory

    public static func getError() -> OpenDirectoryError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EBADF: return .badFileDescriptor
        case .EMFILE: return .noMoreProcessFileDescriptors
        case .ENFILE: return .noMoreSystemFileDescriptors
        case .ENOENT: return .pathDoesNotExist
        case .ENOMEM: return .outOfMemory
        case .ENOTDIR: return .notDirectory
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
    case notDirectory
    case readOnlyFileSystem

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
        case .ENOTDIR: return .notDirectory
        case .EROFS: return .readOnlyFileSystem
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
    case noKernelMemory
    case directoryNotEmpty
    case readOnlyFileSystem

    public static func getError() -> DeleteDirectoryError {
        switch ErrNo.lastError {
        case .EACCES, .EPERM: return .permissionDenied
        case .EBUSY: return .directoryInUse
        case .EFAULT: return .badAddress
        case .EINVAL: return .relativePath
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT, .ENOTDIR: return .noRouteToPath
        case .ENOMEM: return .noKernelMemory
        case .ENOTEMPTY: return .directoryNotEmpty
        case .EROFS: return .readOnlyFileSystem
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
    case notDirectory
    case fileTooLarge

    public static func getError() -> StatError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EBADF: return .badFileDescriptor
        case .EFAULT: return .badAddress
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .noRouteToPath
        case .ENOMEM: return .outOfMemory
        case .ENOTDIR: return .notDirectory
        case .EOVERFLOW: return .fileTooLarge
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
    case notDirectory

	public static func getError() -> PathError {
		switch ErrNo.lastError {
            case .EACCES: return .permissionDenied
            case .EINVAL: return .emptyPath
            case .EIO: return .ioError
            case .ELOOP: return .tooManySymlinks
            case .ENAMETOOLONG: return .pathnameTooLong
            case .ENOMEM: return .outOfMemory
            case .ENOENT: return .pathDoesNotExist
            case .ENOTDIR: return .notDirectory
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

public enum ReadError: TrailBlazerError {
    case unknown
    case wouldBlock
    case badFileDescriptor
    case badBufferAddress
    case interruptedBySignal
    case cannotReadFileDescriptor
    case ioError
    case isDirectory

	public static func getError() -> ReadError {
          switch ErrNo.lastError {
          case .EAGAIN, .EWOULDBLOCK: return .wouldBlock
          case .EBADF: return .badFileDescriptor
          case .EFAULT: return .badBufferAddress
          case .EINTR: return .interruptedBySignal
          case .EINVAL: return .cannotReadFileDescriptor
          case .EIO: return .ioError
          case .EISDIR: return .isDirectory
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

	public static func getError() -> SeekError {
        switch ErrNo.lastError {
        case .EBADF: return .fileDescriptorIsNotOpen
        case .EINVAL, .ENXIO: return .invalidOffset
        case .EOVERFLOW: return .offsetTooLarge
        case .ESPIPE: return .fileDescriptorIsNotFile
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
    case notDirectory

    public static func getError() -> RealPathError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EINVAL: return .emptyPath
        case .EIO: return .ioError
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOMEM: return .outOfMemory
        case .ENOENT: return .pathDoesNotExist
        case .ENOTDIR: return .notDirectory
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
        default: return .unknown
        }
    }
}
