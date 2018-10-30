#if os(Linux)
import func Glibc.socket
import func Glibc.close
#else
import func Darwin.socket
import func Darwin.close
#endif
private let cSocket = socket
private let cCloseSocket = close

public protocol SocketOption: Hashable {
    var domain: SocketDomain { get }
    var type: SocketType { get }
    var `protocol`: SocketProtocol { get }
    var options: SocketOptions { get }
}

public struct TCPSocket: SocketOption {
    public let domain: SocketDomain
    public let type: SocketType = .stream
    public let `protocol`: SocketProtocol = .tcp
    public let options: SocketOptions

    public init(domain: SocketDomain, options: SocketOptions = []) {
        self.domain = domain
        self.options = options
    }
}

public struct UDPSocket: SocketOption {
    public let domain: SocketDomain
    public let type: SocketType = .datagram
    public let `protocol`: SocketProtocol = .udp
    public let options: SocketOptions

    public init(domain: SocketDomain, options: SocketOptions = []) {
        self.domain = domain
        self.options = options
    }
}

public struct GenericSocket: SocketOption {
    public let domain: SocketDomain
    public let type: SocketType
    public let `protocol`: SocketProtocol
    public let options: SocketOptions

    public init(domain: SocketDomain, type: SocketType, `protocol`: SocketProtocol, options: SocketOptions = []) {
        self.domain = domain
        self.type = type
        self.protocol = `protocol`
        self.options = options
    }

    public init<Socket: SocketOption>(_ socket: Socket) {
        domain = socket.domain
        type = socket.type
        `protocol` = socket.protocol
        options = socket.options
    }
}

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
