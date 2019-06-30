#if os(Linux)
import func Glibc.bind
import func Glibc.connect
#else
import func Darwin.bind
import func Darwin.connect
#endif
private let cConnectSocket = connect
private let cBindSocket = bind

public typealias OpenSocket = Open<SocketPath>

private let addressSize = SocketAddressSize(MemoryLayout<LocalSocketAddress>.size)

public extension Open where PathType == SocketPath {
    func connect() throws -> Connection {
        guard let descriptor = self.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        let addr = try path.convertToCAddress()

        guard cConnectSocket(descriptor, addr, addressSize) == 0 else {
            throw ConnectionError.getError()
        }

        return Connection(self)
    }

    func bind() throws -> Binding {
        guard let descriptor = self.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        let addr = try path.convertToCAddress()

        guard cBindSocket(descriptor, addr, addressSize) == 0 else {
            throw BindError.getError()
        }

        return Binding(self)
    }
}
