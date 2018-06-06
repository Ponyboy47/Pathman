import ErrNo

public protocol TrailBlazerError: Error {
    static func getError() -> Self
}

public enum OpenError: TrailBlazerError {
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
    case noRouteToPathname
    case noKernelMemory
    case fileSystemFull
    case notADirectory
    case deviceNotOpened
    case noTempFS
    case readOnlyFileSystem
    case deviceBusy
    case wouldBlock
    case createWithoutMode

    public static func getError() -> OpenError {
		return .getError(flags: [])
    }

	public static func getError(flags: OpenFileFlags) -> OpenError {
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
        case .ENOENT: return .noRouteToPathname
        case .ENOMEM: return .noKernelMemory
        case .ENOSPC: return .fileSystemFull
        case .ENOTDIR: return .notADirectory
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

public enum CloseError: TrailBlazerError {
    case unknown
    case badFileDescriptor
    case interruptedBySignal
    case ioError

    public static func getError() -> CloseError {
        switch ErrNo.lastError {
        case .EBADF: return .badFileDescriptor
        case .EINTR: return .interruptedBySignal
        case .EIO: return .ioError
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
    case noRouteToPathname
    case outOfMemory
    case notADirectory
    case fileTooLarge

    public static func getError() -> StatError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EBADF: return .badFileDescriptor
        case .EFAULT: return .badAddress
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOENT: return .noRouteToPathname
        case .ENOMEM: return .outOfMemory
        case .ENOTDIR: return .notADirectory
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
    case notADirectory

	public static func getError() -> PathError {
		switch ErrNo.lastError {
            case .EACCES: return .permissionDenied
            case .EINVAL: return .emptyPath
            case .EIO: return .ioError
            case .ELOOP: return .tooManySymlinks
            case .ENAMETOOLONG: return .pathnameTooLong
            case .ENOMEM: return .outOfMemory
            case .ENOENT: return .pathDoesNotExist
            case .ENOTDIR: return .notADirectory
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
          case 0: fallthrough
          case .ENOENT: fallthrough
          case .ESRCH: fallthrough
          case .EBADF: fallthrough
          case .EPERM: return .userDoesNotExist
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
          case .EAGAIN: fallthrough
          case .EWOULDBLOCK: return .wouldBlock
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
        case .EINVAL: fallthrough
        case .ENXIO: return .invalidOffset
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
    case notADirectory

    public static func getError() -> RealPathError {
        switch ErrNo.lastError {
        case .EACCES: return .permissionDenied
        case .EINVAL: return .emptyPath
        case .EIO: return .ioError
        case .ELOOP: return .tooManySymlinks
        case .ENAMETOOLONG: return .pathnameTooLong
        case .ENOMEM: return .outOfMemory
        case .ENOENT: return .pathDoesNotExist
        case .ENOTDIR: return .notADirectory
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
        case .EAGAIN: fallthrough
        case .EWOULDBLOCK: return .wouldBlock
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
