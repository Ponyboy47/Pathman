#if os(Linux)
import func Glibc.socket
import func Glibc.close
#else
import func Darwin.socket
import func Darwin.close
#endif
private let cSocket = socket
private let cCloseSocket = close

public struct SocketPath: Path, Openable {
    public typealias OpenOptionsType = GenericSocket
    public static let pathType: PathType = .socket

    // swiftlint:disable identifier_name
    public var _path: String

    public let _info: StatInfo
    // swiftlint:enable identifier_name

    /**
    Initialize from another Path

    - Parameter path: The path to copy
    */
    public init?(_ path: GenericPath) {
        // Cannot initialize a directory from a non-directory type
        if path.exists {
            guard path._info.type == .socket else { return nil }
        }

        _path = path._path
        _info = StatInfo(path)
        try? _info.getInfo()
    }

    public func open<Socket: SocketOption>(socket: Socket) throws -> Open<SocketPath> {
        return try open(options: GenericSocket(socket))
    }

    public func open(domain: SocketDomain,
                     type: SocketType,
                     protocol: SocketProtocol,
                     options: SocketOptions = []) throws -> Open<SocketPath> {
        return try open(options: GenericSocket(domain: domain, type: type, protocol: `protocol`, options: options))
    }

    public func open(options: GenericSocket) throws -> Open<SocketPath> {
        let fileDescriptor = try cSocket(options.domain.rawValue,
                                        options.type.rawValue | options.options.rawValue,
                                        options.protocol.rawValue) ?! SocketError.getError()
        return Open<SocketPath>(self, descriptor: fileDescriptor, options: options)
    }

    public static func close(opened: Open<SocketPath>) throws {
        guard cCloseSocket(opened.descriptor) != -1 else { throw CloseSocketError.getError() }
    }
}
