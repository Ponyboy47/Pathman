import struct Foundation.URL

public final class Connection {
    public let path: SocketPath
    public private(set) var descriptor: SocketPath.Descriptor?
    public let openOptions: SocketPath.OpenOptions

    public static var defaultByteCount: ByteRepresentable = 32.kb
    public static let emptyReadFlags: ReceiveFlags = .none
    public static let emptyWriteFlags: SendFlags = .none

    let opened: Open<SocketPath>

    init(_ opened: Open<SocketPath>) {
        self.opened = opened

        path = opened.path
        descriptor = opened.descriptor
        openOptions = opened.openOptions
    }

    deinit {
        guard descriptor != nil else { return }
        try? SocketPath.shutdown(connected: self)
        // No need to close the opened object. It should become deinitialized
        // (and therefore closed) now since this connection object holds the
        // only reference to it
    }
}

extension Connection: Equatable {
    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.path == rhs.path && lhs.descriptor == rhs.descriptor
    }
}

extension Connection: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(descriptor)
        hasher.combine(openOptions)
    }
}

extension Connection: CustomStringConvertible {
    public var description: String {
        var data: [(key: String, value: CustomStringConvertible)] = []

        data.append((key: "path", value: path))
        data.append((key: "options", value: String(describing: openOptions)))

        return "\(Swift.type(of: self))(\(data.map { "\($0.key): \($0.value)" }.joined(separator: ", ")))"
    }
}
