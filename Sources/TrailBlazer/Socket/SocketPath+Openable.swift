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

        public init(type: SocketType) {
            self.type = type
        }
    }

    public func open(type: SocketType) throws -> Open<SocketPath> {
        return try open(options: SocketOptions(type: type))
    }

    public func open(options: SocketOptions) throws -> Open<SocketPath> {
        let fileDescriptor = cSocket(options.domain.rawValue,
                                     options.type.rawValue,
                                     0)

        guard fileDescriptor != -1 else {
            throw SocketError.getError()
        }

        return Open<SocketPath>(self, descriptor: fileDescriptor, options: options)
    }

    public static func close(opened: Open<SocketPath>) throws {
        guard cCloseSocket(opened.descriptor) != -1 else { throw CloseSocketError.getError() }

        opened.path.buffer = nil
        opened.path.bufferSize = nil
    }
}
