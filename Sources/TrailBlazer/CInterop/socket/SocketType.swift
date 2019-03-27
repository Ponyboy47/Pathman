#if os(Linux)
import struct Glibc.__socket_type
import let Glibc.SOCK_DGRAM
import let Glibc.SOCK_STREAM
#else
import let Darwin.SOCK_DGRAM
import let Darwin.SOCK_STREAM
#endif

public struct SocketType: Hashable {
    let rawValue: OptionInt

    /// Provides sequenced, reliable, two-way, connection-based byte streams.
    /// An out-of-band data transmission mechanism may be supported.
    public static let stream = SocketType(rawValue: SOCK_STREAM)
    /// Supports datagrams (connectionless, unreliable messages of a fixed
    /// maximum length).
    public static let datagram = SocketType(rawValue: SOCK_DGRAM)

    private init(rawValue: UInt32) {
        self.rawValue = OptionInt(rawValue)
    }

    #if os(Linux)
    private init(rawValue: __socket_type) {
        self.init(rawValue: OptionInt(rawValue.rawValue))
    }
    #endif

    private init(rawValue: OptionInt) {
        self.rawValue = rawValue
    }
}

extension SocketType: CustomStringConvertible {
    public var description: String {
        let type: String
        switch self {
        case .stream: type = "stream"
        case .datagram: type = "datagram"
        default: type = "unknown"
        }

        return "\(Swift.type(of: self)).\(type)"
    }
}
