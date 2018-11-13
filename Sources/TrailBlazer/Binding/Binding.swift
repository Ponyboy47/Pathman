import struct Foundation.URL

public final class Binding {
    public let path: SocketPath
    public let descriptor: SocketPath.DescriptorType
    public let fileDescriptor: FileDescriptor
    public let openOptions: SocketPath.OpenOptionsType

    public var isListening = false

    let opened: Open<SocketPath>

    init(_ opened: Open<SocketPath>) {
        self.opened = opened

        path = opened.path
        descriptor = opened.descriptor
        fileDescriptor = opened.fileDescriptor
        openOptions = opened.openOptions
    }

    deinit {
        var path = self.path
        try? path.delete()
        // No need to close the opened object. It should become deinitialized
        // (and therefore closed) now since this connection object holds the
        // only reference to it
    }
}

extension Binding: Equatable {
    public static func == (lhs: Binding, rhs: Binding) -> Bool {
        return lhs.path == rhs.path && lhs.fileDescriptor == rhs.fileDescriptor
    }
}

extension Binding: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(fileDescriptor)
        hasher.combine(openOptions)
    }
}

extension Binding: CustomStringConvertible {
    public var description: String {
        var data: [(key: String, value: CustomStringConvertible)] = []

        data.append((key: "path", value: path))
        data.append((key: "options", value: String(describing: openOptions)))

        return "\(Swift.type(of: self))(\(data.map({ return "\($0.key): \($0.value)" }).joined(separator: ", ")))"
    }
}
