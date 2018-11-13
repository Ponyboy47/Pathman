#if os(Linux)
import func Glibc.accept
#else
import func Darwin.accept
#endif
private let cAcceptConnection = accept

private let localSocketAddressSize = MemoryLayout<LocalSocketAddress>.size

extension Binding {
    public func accept() throws -> Connection {
        var address = SocketAddress()
        var addressSize = SocketAddressSize()

        let connectionFileDescriptor = cAcceptConnection(fileDescriptor, &address, &addressSize)

        guard connectionFileDescriptor != -1 else {
            throw AcceptError.getError()
        }

        // Since we can only accept connections from a local socket, the
        // address had better be another local socket
        guard addressSize == localSocketAddressSize else {
            throw AcceptError.connectionTypeMismatch
        }

        var localAddress = unsafeBitCast(address, to: LocalSocketAddress.self)
        let localAddressSize = MemoryLayout.size(ofValue: localAddress.sun_path)
        let localAddressPath = withUnsafePointer(to: &localAddress.sun_path) { ptr -> SocketPath in
            return SocketPath(ptr.withMemoryRebound(to: CChar.self, capacity: localAddressSize) {
                return String(cString: $0)
            }) !! "Accepted socket connection is somehow not a local/unix socket path"
        }

        return Connection(Open(localAddressPath, descriptor: connectionFileDescriptor, options: openOptions))
    }
}
