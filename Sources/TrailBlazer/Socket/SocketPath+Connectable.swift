#if os(Linux)
import func Glibc.shutdown
import let Glibc.SHUT_RDWR
#else
import func Darwin.shutdown
import let Darwin.SHUT_RDWR
#endif
private let cShutdown = shutdown

extension SocketPath {
    public func connect<AddressType: Address>(to address: AddressType,
                                              options: SocketOptions) throws -> Connection {
        return try open(options: options).connect(to: address)
    }

    public func connect<AddressType: Address,
                        Socket: SocketOption>(to address: AddressType,
                                              type: Socket.Type) throws -> Connection {
        return try connect(to: address, options: SocketOptions(type: type))
    }

    public static func shutdown(connected: Connection) throws {
        guard cShutdown(connected.descriptor, OptionInt(SHUT_RDWR)) != -1 else { throw ShutdownError.getError() }
    }
}
