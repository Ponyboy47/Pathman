#if os(Linux)
import func Glibc.socket
import func Glibc.close
#else
import func Darwin.socket
import func Darwin.close
#endif
private let cSocket = socket
private let cCloseSocket = close

extension SocketPath: Openable {
    public typealias OpenOptionsType = SocketOptions

    public struct SocketOptions: OpenOptionable {
        public let domain: SocketDomain = .local
        public let type: SocketType
        public let `protocol`: SocketProtocol

        public init<SocketType: SocketOption>(type socket: SocketType.Type) {
            self.type = socket.type
            self.protocol = socket.protocol
        }
    }

    public func open<SocketType: SocketOption>(type: SocketType.Type) throws -> Open<SocketPath> {
        return try open(options: SocketOptions(type: type))
    }

    public func open(options: SocketOptions) throws -> Open<SocketPath> {
        let fileDescriptor = cSocket(options.domain.rawValue,
                                     options.type.rawValue,
                                     options.protocol.rawValue)

        guard fileDescriptor != -1 else {
            throw SocketError.getError()
        }

        return Open<SocketPath>(self, descriptor: fileDescriptor, options: options)
    }

    public static func close(opened: Open<SocketPath>) throws {
        guard cCloseSocket(opened.descriptor) != -1 else { throw CloseSocketError.getError() }
    }
}

public protocol SocketOption: Hashable {
    static var type: SocketType { get }
    static var `protocol`: SocketProtocol { get }
}

public struct TCPSocket: SocketOption {
    public static let type: SocketType = .stream
    public static let `protocol`: SocketProtocol = .tcp
}

public struct UDPSocket: SocketOption {
    public static let type: SocketType = .datagram
    public static let `protocol`: SocketProtocol = .udp
}
