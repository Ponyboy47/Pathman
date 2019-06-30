import ErrNo
// swiftlint:disable file_length

/// The Error type used by anything that throws in this library
public protocol TrailBlazerError: Error, Equatable, CaseIterable, ExpressibleByIntegerLiteral
    where AllCases == [Self],
    IntegerLiteralType == ErrNo.RawValue {
    var errors: [ErrNo] { get set }

    init(error: ErrNo?)
}

extension ErrNo {
    static var EIRRELEVANT: ErrNo { return ErrNo(rawValue: -1000) }
    static var EIRRELEVANT2: ErrNo { return ErrNo(rawValue: -1001) }
}

public extension TrailBlazerError {
    static var accessDenied: Self { return Self(error: .EACCES) }
    static var permissionDenied: Self { return Self(error: .EPERM) }
    static var quotaReached: Self { return Self(error: .EDQUOT) }
    static var segFault: Self { return Self(error: .EFAULT) }
    static var interruptedBySignal: Self { return Self(error: .EINTR) }
    static var noProcessFileDescriptors: Self { return Self(error: .EMFILE) }
    static var noSystemFileDescriptors: Self { return Self(error: .ENFILE) }
    static var pathnameTooLong: Self { return Self(error: .ENAMETOOLONG) }
    static var noDevice: Self { return Self(error: .ENODEV) }
    static var noKernelMemory: Self { return Self(error: .ENOMEM) }
    static var deviceFull: Self { return Self(error: .ENOSPC) }
    static var pathComponentNotDirectory: Self { return Self(error: .ENOTDIR) }
    static var readOnlyFileSystem: Self { return Self(error: .EROFS) }
    static var wouldBlock: Self { return Self(errors: .EWOULDBLOCK, .EAGAIN) }
    static var ioError: Self { return Self(error: .EIO) }
    static var badFileDescriptor: Self { return Self(error: .EBADF) }
    static var tooManySymlinks: Self { return Self(error: .ELOOP) }
    static var noRouteToPath: Self { return Self(error: .ENOENT) }
    static var operationNotSupported: Self { return Self(error: .EOPNOTSUPP) }
    static var isDirectory: Self { return Self(error: .EISDIR) }
    static var notASocket: Self { return Self(error: .ENOTSOCK) }
    static var addressInUse: Self { return Self(error: .EADDRINUSE) }

    static var unknown: Self { return Self(error: ErrNo(rawValue: -42)) }

    init(integerLiteral value: ErrNo.RawValue) {
        let error = ErrNo(rawValue: value)
        self.init(error: error)
    }

    init(errors: [ErrNo]) {
        self.init(error: errors.first)
        self.errors += errors.dropFirst()
    }

    init(errors: ErrNo...) {
        self.init(errors: errors)
    }

    func contains(_ error: ErrNo) -> Bool { return errors.contains(error) }

    /// A function used to return the Error based on the ErrNo
    static func getError() -> Self {
        return Self.allCases.filter { $0.contains(ErrNo.lastError) }.first ?? .unknown
    }

    static func ~= (lhs: Self, rhs: Error) -> Bool {
        guard let selfError = rhs as? Self else { return false }
        return selfError == lhs
    }
}

// Creating files uses the open(2) call so it's errors are the same
/// Errors thrown when a FilePath is created (see open(2))
public typealias CreateFileError = OpenFileError

/// Errors thrown when a FilePath is opened (see open(2))
public struct OpenFileError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let wouldBlock = OpenFileError(error: .EWOULDBLOCK)
    public static let fileTooLarge = OpenFileError(error: .EFBIG)
    public static let improperUseOfDirectory = OpenFileError(error: .EISDIR)
    public static let invalidPermissions = OpenFileError(error: .EIRRELEVANT)
    public static let createWithoutMode = OpenFileError(error: .EIRRELEVANT2)
    public static let invalidMode = OpenFileError(error: .EINVAL)
    public static let deviceNotOpened = OpenFileError(error: .ENXIO)
    public static let pathBusy = OpenFileError(error: .ETXTBSY)
    public static let pathExists = OpenFileError(error: .EEXIST)
    #if os(macOS)
    public static let lockedDevice = OpenFileError(error: .EAGAIN)
    #endif

    public static let allCases: [OpenFileError] = {
        var cases: [OpenFileError] = [
            .accessDenied, .quotaReached, .pathExists, .segFault, .fileTooLarge,
            .interruptedBySignal, .invalidMode, .improperUseOfDirectory,
            .tooManySymlinks, .noProcessFileDescriptors, .pathnameTooLong,
            .noSystemFileDescriptors, .noDevice, .noRouteToPath, .noKernelMemory,
            .deviceFull, .pathComponentNotDirectory, .deviceNotOpened,
            .permissionDenied, .readOnlyFileSystem, .pathBusy, .wouldBlock,
            .operationNotSupported
        ]

        #if os(macOS)
        cases += [.lockedDevice, .ioError]
        #endif

        return cases
    }()

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown when a FilePath is closed (see close(2))
public struct CloseFileError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let allCases: [CloseFileError] = {
        [
            .badFileDescriptor, .interruptedBySignal, .ioError
        ]
    }()

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown when a FilePath is deleted
public typealias DeleteFileError = UnlinkError

/// Errors thrown when a path is unlinked (see unlink(2))
public struct UnlinkError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let pathInUse = UnlinkError(error: .EBUSY)

    public static let allCases: [UnlinkError] = [
        .accessDenied, .permissionDenied, .pathInUse, .segFault, .ioError,
        .isDirectory, .tooManySymlinks, .pathnameTooLong, .noRouteToPath,
        .pathComponentNotDirectory, .noKernelMemory, .readOnlyFileSystem
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown when a path is linked (see link(2))
public struct LinkError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let alreadyExists = LinkError(error: .EEXIST)
    public static let pathTypeMismatch = LinkError(error: .EIRRELEVANT)
    public static let linkLimitReached = LinkError(error: .EMLINK)
    public static let pathsOnDifferentFileSystems = LinkError(error: .EXDEV)

    public static let allCases: [LinkError] = [
        .accessDenied, .quotaReached, .alreadyExists, .segFault, .ioError,
        .tooManySymlinks, .linkLimitReached, .pathnameTooLong, .noRouteToPath,
        .noKernelMemory, .deviceFull, .pathComponentNotDirectory,
        .operationNotSupported, .readOnlyFileSystem
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown when a path is symlinked (see symlink(2))
public struct SymlinkError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let alreadyExists = SymlinkError(error: .EEXIST)

    public static let allCases: [SymlinkError] = [
        .accessDenied, .quotaReached, .alreadyExists, .segFault, .ioError,
        .tooManySymlinks, .pathnameTooLong, .noRouteToPath, .noKernelMemory,
        .deviceFull, .pathComponentNotDirectory, .operationNotSupported,
        .readOnlyFileSystem
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown when a DirectoryPath is opened (see opendir(3))
public struct OpenDirectoryError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let pathNotDirectory = OpenDirectoryError(error: .ENOTDIR)

    public static let allCases: [OpenDirectoryError] = [
        .noRouteToPath, .pathNotDirectory
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown when a DirectoryPath is closed (see closedir(3))
public struct CloseDirectoryError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let invalidDirectoryStream = CloseDirectoryError(error: .EBADF)

    public static let allCases: [CloseDirectoryError] = [
        .invalidDirectoryStream
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown when a DirectoryPath is created (see mkdir(2))
public struct CreateDirectoryError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let tooManySymlinks = CreateDirectoryError(error: .ELOOP)
    public static let tooManyLinks = CreateDirectoryError(error: .EMLINK)
    public static let pathExists = CreateDirectoryError(error: .EEXIST)
    #if os(macOS)
    public static let pathIsRootDirectory = CreateDirectoryError(error: .EISDIR)
    #endif

    public static let allCases: [CreateDirectoryError] = {
        var cases: [CreateDirectoryError] = [
            .accessDenied, .permissionDenied, .quotaReached, .pathExists, .segFault,
            .tooManySymlinks, .tooManyLinks, .pathnameTooLong, .noRouteToPath,
            .noKernelMemory, .deviceFull, .pathComponentNotDirectory, .readOnlyFileSystem
        ]

        #if os(macOS)
        cases.append(.pathIsRootDirectory)
        #endif

        return cases
    }()

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown when a DirectoryPath is deleted (see rmdir(2))
public struct DeleteDirectoryError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let directoryInUse = DeleteDirectoryError(error: .EBUSY)
    public static let relativePath = DeleteDirectoryError(error: .EINVAL)
    public static let directoryNotEmpty = DeleteDirectoryError(error: .ENOTEMPTY)

    public static let allCases: [DeleteDirectoryError] = [
        .accessDenied, .permissionDenied, .directoryInUse, .segFault,
        .relativePath, .tooManySymlinks, .pathnameTooLong, .noRouteToPath,
        .pathComponentNotDirectory, .noKernelMemory, .directoryNotEmpty,
        .readOnlyFileSystem, .ioError
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown getting path information (see stat(2))
public struct StatError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let fileTooLarge = StatError(error: .EOVERFLOW)

    public static let allCases: [StatError] = [
        .accessDenied, .badFileDescriptor, .segFault, .tooManySymlinks,
        .pathnameTooLong, .noRouteToPath, .noKernelMemory,
        .pathComponentNotDirectory, .fileTooLarge, .ioError
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown while getting information about a user (see getpwnam(2) or getpwuid(2))
public struct UserInfoError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let userDoesNotExist = UserInfoError(errors: ErrNo(rawValue: 0), .ENOENT, .ESRCH, .EBADF, .EPERM)
    public static let invalidHomeDirectory = UserInfoError(error: .EIRRELEVANT)

    public static let allCases: [UserInfoError] = [
        .userDoesNotExist, .interruptedBySignal, .ioError, noProcessFileDescriptors,
        .noSystemFileDescriptors, .noKernelMemory
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown while getting information about a group (see getgrnam(2) or getgrgid(2))
public struct GroupInfoError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let groupDoesNotExist = GroupInfoError(errors: ErrNo(rawValue: 0), .ENOENT, .ESRCH, .EBADF, .EPERM)

    public static let allCases: [GroupInfoError] = [
        .groupDoesNotExist, .interruptedBySignal, .ioError, noProcessFileDescriptors,
        .noSystemFileDescriptors, .noKernelMemory
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown by trying to read a fileDescriptor (see read(2))
public struct ReadError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let cannotReadFileDescriptor = ReadError(error: .EINVAL)
    #if os(macOS)
    public static let bufferAllocationFailed = ReadError(error: .ENOBUFS)
    public static let deviceError = ReadError(error: .ENXIO)
    public static let connectionReset = ReadError(error: .ECONNRESET)
    public static let notConnected = ReadError(error: .ENOTCONN)
    public static let timeout = ReadError(error: .ETIMEDOUT)
    #endif

    public static let allCases: [ReadError] = {
        var cases: [ReadError] = [
            .wouldBlock, .badFileDescriptor, .segFault, .interruptedBySignal,
            .cannotReadFileDescriptor, .ioError, .isDirectory
        ]

        #if os(macOS)
        cases += [
            .bufferAllocationFailed, .deviceError, .connectionReset,
            .notConnected, .timeout
        ]
        #endif

        return cases
    }()

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }

    public init() { errors = [] }
}

/// Errors thrown by trying to seek to an offset for a fileDescriptor (see seek(2))
public struct SeekError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let unknownOffsetType = SeekError(error: .EIRRELEVANT)
    public static let fileDescriptorIsNotOpen = SeekError(error: .EBADF)
    public static let invalidOffset = SeekError(error: .EINVAL)
    public static let offsetTooLarge = SeekError(error: .EOVERFLOW)
    public static let fileDescriptorIsPipe = SeekError(error: .ESPIPE)
    #if os(macOS)
    public static let noData = SeekError(error: .ENXIO)
    #endif

    public static let allCases: [SeekError] = {
        var cases: [SeekError] = [
            .fileDescriptorIsNotOpen, .invalidOffset, .offsetTooLarge, .fileDescriptorIsPipe
        ]

        #if os(macOS)
        cases.append(.noData)
        #endif

        return cases
    }()

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown while expanding relative paths or symlinks (see realpath(3))
public struct RealPathError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let emptyPath = RealPathError(error: .EINVAL)
    public static let pathComponentTooLong = RealPathError(error: .EIRRELEVANT)

    public static let allCases: [RealPathError] = [
        .accessDenied, .emptyPath, .ioError, .tooManySymlinks, .pathnameTooLong,
        .noKernelMemory, .noRouteToPath, .pathComponentNotDirectory
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown by trying to write to a fileDescriptor (see write(2))
public struct WriteError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let unconnectedSocket = WriteError(error: .EDESTADDRREQ)
    public static let fileTooLarge = WriteError(error: .EFBIG)
    public static let cannotWriteToFileDescriptor = WriteError(error: .EINVAL)
    public static let pipeOrSocketClosed = WriteError(error: .EPIPE)
    #if os(macOS)
    public static let notConnected = WriteError(error: .ECONNRESET)
    public static let networkDown = WriteError(error: .ENETDOWN)
    public static let networkUnreachable = WriteError(error: .ENETUNREACH)
    public static let deviceError = WriteError(error: .ENXIO)
    #endif

    public static let allCases: [WriteError] = {
        var cases: [WriteError] = [
            .wouldBlock, .badFileDescriptor, .unconnectedSocket, .quotaReached,
            .segFault, .fileTooLarge, .interruptedBySignal, .cannotWriteToFileDescriptor,
            .ioError, .deviceFull, .permissionDenied, .pipeOrSocketClosed
        ]

        #if os(macOS)
        cases += [
            .notConnected, .networkDown, .networkUnreachable, .deviceError
        ]
        #endif

        return cases
    }()

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }

    public init() { errors = [] }
}

/// Errors thrown while changing Path ownership (see chown(2))
public struct ChangeOwnershipError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let allCases: [ChangeOwnershipError] = [
        .accessDenied, .permissionDenied, .segFault, .tooManySymlinks,
        .pathnameTooLong, .noRouteToPath, .noKernelMemory,
        .pathComponentNotDirectory, .readOnlyFileSystem, .badFileDescriptor,
        .ioError
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown while changing the permissions on a Path (see chmod(2))
public struct ChangePermissionsError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let allCases: [ChangePermissionsError] = [
        .accessDenied, .permissionDenied, .segFault, .ioError, .tooManySymlinks,
        .pathnameTooLong, .noRouteToPath, .noKernelMemory,
        .pathComponentNotDirectory, .readOnlyFileSystem, .badFileDescriptor
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown by moving or renaming a Path (see rename(2))
public struct MoveError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let pathInUse = MoveError(error: .EBUSY)
    public static let invalidNewPath = MoveError(error: .EINVAL)
    public static let newPathIsDirectoryButOldPathIsNot = MoveError(error: .EISDIR)
    public static let symlinkLimitReached = MoveError(error: .EMLINK)
    public static let newPathIsNonEmptyDirectory = MoveError(errors: .ENOTEMPTY, .EEXIST)
    public static let pathsOnDifferentDevices = MoveError(error: .EXDEV)
    public static let moveToDifferentPathType = MoveError(error: .EIRRELEVANT)

    public static let allCases: [MoveError] = [
        .accessDenied, .permissionDenied, .pathInUse, .quotaReached, .segFault,
        .invalidNewPath, .newPathIsDirectoryButOldPathIsNot, .tooManySymlinks,
        .symlinkLimitReached, .pathnameTooLong, .noRouteToPath, .noKernelMemory,
        .deviceFull, .pathComponentNotDirectory, .newPathIsNonEmptyDirectory,
        .readOnlyFileSystem, .pathsOnDifferentDevices
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

/// Errors thrown by creating/opening a temporary file/directory (see mkstemp(3)/mkdtemp(3))
public typealias MakeTemporaryError = CreateFileError

public struct ChDirError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let allCases: [ChDirError] = [
        .accessDenied, .segFault, .ioError, .tooManySymlinks, .pathnameTooLong,
        .noRouteToPath, .noKernelMemory, .pathComponentNotDirectory
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

public struct CWDError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let unlinkedCWD = CWDError(error: .ENOENT)

    public static let allCases: [CWDError] = [
        .accessDenied, .segFault, .pathnameTooLong, .noKernelMemory, .unlinkedCWD
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

public struct SocketError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let unsupportedDomain = SocketError(error: .EAFNOSUPPORT)
    public static let domainNotAvailable = SocketError(error: .EINVAL)
    public static let noKernelMemory = SocketError(errors: .ENOBUFS, .ENOMEM)
    public static let unsupportedProtocol = SocketError(error: .EPROTONOSUPPORT)
    #if os(macOS)
    public static let unsupportedType = SocketError(error: .EPROTOTYPE)
    #endif

    public static let allCases: [SocketError] = {
        var cases: [SocketError] = [
            .accessDenied, .unsupportedDomain, .domainNotAvailable, .noProcessFileDescriptors,
            .noSystemFileDescriptors, .noKernelMemory, .unsupportedProtocol
        ]

        #if os(macOS)
        cases.append(unsupportedType)
        #endif

        return cases
    }()

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

public typealias CloseSocketError = CloseFileError

public struct ShutdownError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let notConnected = ShutdownError(error: .ENOTCONN)

    public static let allCases: [ShutdownError] = [
        .badFileDescriptor, .notConnected, .notASocket
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

public struct ConnectionError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let addressUnavailable = ConnectionError(error: .EADDRNOTAVAIL)
    public static let invalidAddressForDomain = ConnectionError(error: .EAFNOSUPPORT)
    public static let noRouteInCache = ConnectionError(error: .EAGAIN)
    public static let wouldBlock = ConnectionError(error: .EALREADY)
    public static let connectionRefused = ConnectionError(error: .ECONNREFUSED)
    public static let previousConnectionInProgress = ConnectionError(error: .EINPROGRESS)
    public static let alreadyConnected = ConnectionError(error: .EISCONN)
    public static let networkUnreachable = ConnectionError(error: .ENETUNREACH)
    public static let invalidTypeForDomain = ConnectionError(error: .EPROTOTYPE)
    public static let timedOut = ConnectionError(error: .ETIMEDOUT)

    public static let allCases: [ConnectionError] = [
        .accessDenied, .permissionDenied, .addressInUse, .addressUnavailable,
        .invalidAddressForDomain, .noRouteInCache, .wouldBlock,
        .badFileDescriptor, .connectionRefused, .segFault,
        .previousConnectionInProgress, .interruptedBySignal, .alreadyConnected,
        .networkUnreachable, .notASocket, .invalidTypeForDomain, .timedOut
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

public struct BindError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let socketAlreadyBound = BindError(error: .EINVAL)
    public static let nonexistentInterfaceOrAddress = BindError(error: .EADDRNOTAVAIL)

    public static let allCases: [BindError] = [
        .accessDenied, .addressInUse, .badFileDescriptor, .socketAlreadyBound,
        .notASocket, .nonexistentInterfaceOrAddress, .segFault,
        .tooManySymlinks, .pathnameTooLong, .noRouteToPath, .noKernelMemory,
        .pathComponentNotDirectory, .readOnlyFileSystem
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

public struct ListenError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let socketCannotListen = ListenError(error: .EOPNOTSUPP)

    public static let allCases: [ListenError] = [
        .addressInUse, .badFileDescriptor, .notASocket, .socketCannotListen
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

public struct AcceptError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let connectionAborted = AcceptError(error: .ECONNABORTED)
    public static let notListening = AcceptError(error: .EINVAL)
    public static let noKernelMemory = AcceptError(errors: .ENOBUFS, .ENOMEM)
    public static let invalidSocketType = AcceptError(error: .EOPNOTSUPP)
    public static let protocolError = AcceptError(error: .EPROTO)

    public static let allCases: [AcceptError] = [
        .wouldBlock, .badFileDescriptor, .connectionAborted, .segFault,
        .interruptedBySignal, .notListening, .noProcessFileDescriptors,
        .noSystemFileDescriptors, .noKernelMemory, .notASocket,
        .invalidSocketType, .protocolError, .permissionDenied
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}

public struct SendError: TrailBlazerError {
    public var errors: [ErrNo]

    public static let connectionReset = SendError(error: .ECONNRESET)
    public static let missingDestination = SendError(error: .EDESTADDRREQ)
    public static let invalidFlags = SendError(error: .EINVAL)
    public static let alreadyConnected = SendError(error: .EISCONN)
    public static let notConnected = SendError(error: .ENOTCONN)
    public static let invalidMessageSize = SendError(error: .EMSGSIZE)
    public static let connectionShutdown = SendError(error: .EPIPE)

    public static let allCases: [SendError] = [
        .accessDenied, .wouldBlock, .badFileDescriptor, .connectionReset,
        .missingDestination, .segFault, .interruptedBySignal, .invalidFlags,
        .alreadyConnected, .notConnected, .invalidMessageSize, .noKernelMemory,
        .notASocket, .connectionShutdown
    ]

    public init(error: ErrNo?) { errors = error == nil ? [] : [error!] }
}
