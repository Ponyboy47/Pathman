#if os(Linux)
import func Glibc.connect
import func Glibc.bind
#else
import func Darwin.connect
import func Darwin.bind
#endif
private let cConnectSocket = connect
private let cBindSocket = bind

public typealias OpenSocket = Open<SocketPath>

private let addressSize = SocketAddressSize(MemoryLayout<LocalSocketAddress>.size)

extension Open where PathType == SocketPath {
    public func connect() throws -> Connection {
        let addr = try path.convertToCAddress()

        guard cConnectSocket(descriptor, addr, addressSize) == 0 else {
            throw ConnectionError.getError()
        }

        return Connection(self)
    }

    public func bind() throws -> Binding {
        let addr = try path.convertToCAddress()

        guard cBindSocket(descriptor, addr, addressSize) == 0 else {
            throw BindError.getError()
        }

        return Binding(self)
    }
}
