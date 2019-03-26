#if os(Linux)
import func Glibc.accept
#else
import func Darwin.accept
#endif
private let cAcceptConnection = accept

public extension Binding {
    func accept() throws -> Connection {
        // No sense storing/casting the accepted connection. We know exactly
        // which path it's connected to and which protocol and there are no ports
        let connectionFileDescriptor = cAcceptConnection(fileDescriptor, nil, nil)

        guard connectionFileDescriptor != -1 else {
            throw AcceptError.getError()
        }

        return Connection(Open(path, descriptor: connectionFileDescriptor, options: openOptions))
    }

    func accept(_ closure: @escaping (Connection) throws -> Void) throws {
        try closure(accept())
    }
}
