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
