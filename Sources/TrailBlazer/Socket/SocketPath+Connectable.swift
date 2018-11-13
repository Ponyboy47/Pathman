#if os(Linux)
import func Glibc.shutdown
import let Glibc.SHUT_RDWR
#else
import func Darwin.shutdown
import let Darwin.SHUT_RDWR
#endif
private let cShutdown = shutdown

extension SocketPath {
    public static func connect(to address: SocketPath,
                        options: SocketOptions) throws -> Connection {
        return try address.open(options: options).connect()
    }

    public static func connect<Socket: SocketOption>(to address: SocketPath,
                                              type: Socket.Type) throws -> Connection {
        return try connect(to: address, options: SocketOptions(type: type))
    }

    public static func connect(to address: SocketPath,
                               options: SocketOptions,
                               closure: (Connection) throws -> ()) throws {
        try closure(connect(to: address, options: options))
    }

    public static func connect<Socket: SocketOption>(to address: SocketPath,
                                                     type: Socket.Type,
                                                     closure: (Connection) throws -> ()) throws {
        try closure(connect(to: address, type: type))
    }

    public func connect(options: SocketOptions) throws -> Connection {
        return try SocketPath.connect(to: self, options: options)
    }

    public func connect<Socket: SocketOption>(type: Socket.Type) throws -> Connection {
        return try SocketPath.connect(to: self, type: type)
    }

    public func connect(options: SocketOptions,
                        closure: (Connection) throws -> ()) throws {
        try closure(connect(options: options))
    }

    public func connect<Socket: SocketOption>(type: Socket.Type,
                                              closure: (Connection) throws -> ()) throws {
        try closure(connect(type: type))
    }

    public static func shutdown(connected: Connection) throws {
        guard cShutdown(connected.descriptor, OptionInt(SHUT_RDWR)) != -1 else { throw ShutdownError.getError() }
    }
}
