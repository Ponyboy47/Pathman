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

public struct UnixSocket: SocketOption {
    #if os(Linux)
    public let domain: SocketDomain = .unix
    #else
    public let domain: SocketDomain = .local
    #endif
    public let type: SocketType
    public let `protocol`: SocketProtocol
    public let options: SocketOptions

    private static let validTypes: [SocketType: SocketProtocol] = [
        .stream: .tcp,
        .datagram: .udp
    ]

    public init?(type: SocketType, options: SocketOptions = []) {
        guard let proto = UnixSocket.validTypes[type] else { return nil }
        self.type = type
        self.protocol = proto
        self.options = options
    }

    public init(socket: TCPSocket) {
        self.type = socket.type
        self.protocol = socket.protocol
        self.options = socket.options
    }

    public init(socket: UDPSocket) {
        self.type = socket.type
        self.protocol = socket.protocol
        self.options = socket.options
    }
}

public typealias LocalSocket = UnixSocket

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
