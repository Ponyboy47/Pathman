#if os(Linux)
import let Glibc.SHUT_RDWR
import func Glibc.shutdown
#else
import let Darwin.SHUT_RDWR
import func Darwin.shutdown
#endif
private let cShutdown = shutdown

public extension SocketPath {
    static func connect(to address: SocketPath,
                        options: SocketOptions) throws -> Connection {
        return try address.open(options: options).connect()
    }

    static func connect(to address: SocketPath,
                        type: SocketType) throws -> Connection {
        return try connect(to: address, options: SocketOptions(type: type))
    }

    static func connect(to address: SocketPath,
                        options: SocketOptions,
                        closure: (Connection) throws -> Void) throws {
        try closure(connect(to: address, options: options))
    }

    static func connect(to address: SocketPath,
                        type: SocketType,
                        closure: (Connection) throws -> Void) throws {
        try closure(connect(to: address, type: type))
    }

    func connect(options: SocketOptions) throws -> Connection {
        return try SocketPath.connect(to: self, options: options)
    }

    func connect(type: SocketType) throws -> Connection {
        return try SocketPath.connect(to: self, type: type)
    }

    func connect(options: SocketOptions,
                 closure: (Connection) throws -> Void) throws {
        try closure(connect(options: options))
    }

    func connect(type: SocketType,
                 closure: (Connection) throws -> Void) throws {
        try closure(connect(type: type))
    }

    static func shutdown(connected: Connection) throws {
        guard cShutdown(connected.descriptor, OptionInt(SHUT_RDWR)) != -1 else { throw ShutdownError.getError() }
    }
}
