#if os(Linux)
import Glibc
#else
import Darwin
#endif

public struct SocketType: Hashable {
    let rawValue: OptionInt
    let connectionless: Bool
    var connectionType: ConnectionType?

    /// Provides sequenced, reliable, two-way, connection-based byte streams.
    /// An out-of-band data transmission mechanism may be supported.
    public static let stream = SocketType(rawValue: SOCK_STREAM, connectionless: false)
    /// Supports datagrams (connectionless, unreliable messages of a fixed
    /// maximum length).
    public static let datagram = SocketType(rawValue: SOCK_DGRAM, connectionless: true)
    /// Provides a sequenced, reliable, two-way connection-based data
    /// transmission path for datagrams of fixed maximum length; a consumer is
    /// required to read an entire packet with each input system call.
    public static let sequencedPackets = SocketType(rawValue: SOCK_SEQPACKET, connectionless: false)
    /// Provides raw network protocol access.
    public static let raw = SocketType(rawValue: SOCK_RAW, connectionless: true)
    /// Provides a reliable datagram layer that does not guarantee ordering.
    public static let reliableDatagram = SocketType(rawValue: SOCK_RDM, connectionless: false)

    private init(rawValue: __socket_type, connectionless: Bool) {
        self.rawValue = OptionInt(rawValue.rawValue)
        self.connectionless = connectionless
    }
}

public enum ConnectionType {
    case client
    case server
}
