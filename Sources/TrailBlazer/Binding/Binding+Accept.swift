#if os(Linux)
import func Glibc.accept
#else
import func Darwin.accept
#endif
private let cAcceptConnection = accept

public extension Binding {
    func accept() throws -> Connection {
        guard let descriptor = self.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }
        // No sense storing/casting the accepted connection. We know exactly
        // which path it's connected to and which protocol and there are no ports
        let connectionDescriptor = cAcceptConnection(descriptor, nil, nil)

        guard connectionDescriptor != -1 else {
            throw AcceptError.getError()
        }

        return Connection(Open(path, descriptor: connectionDescriptor, fileDescriptor: connectionDescriptor, options: openOptions))
    }

    func accept(_ closure: @escaping (Connection) throws -> Void) throws {
        try closure(accept())
    }
}
