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

extension Open where PathType == SocketPath {
    public func connect<AddressType: Address>(to address: AddressType) throws -> Connection {
        var (addr, addrSize) = try address.convertToConnectableAddress()

        guard cConnectSocket(descriptor, &addr, addrSize) == 0 else {
            throw ConnectionError.getError()
        }

        return Connection(self)
    }

    public func bind<AddressType: Address>(to address: AddressType) throws -> Binding {
        var (addr, addrSize) = try address.convertToConnectableAddress()

        guard cBindSocket(descriptor, &addr, addrSize) == 0 else {
            throw BindError.getError()
        }

        return Binding(self)
    }
}
