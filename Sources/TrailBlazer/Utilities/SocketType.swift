#if os(Linux)
import let Glibc.SOCK_STREAM
import let Glibc.SOCK_DGRAM
import let Glibc.SOCK_SEQPACKET
import let Glibc.SOCK_RAW
import let Glibc.SOCK_RDM
import struct Glibc.__socket_type
#else
import let Darwin.SOCK_STREAM
import let Darwin.SOCK_DGRAM
import let Darwin.SOCK_RAW
import struct Darwin.__socket_type
#endif

public struct SocketType: Hashable {
    let rawValue: OptionInt
    let connectionless: Bool

    /// Provides sequenced, reliable, two-way, connection-based byte streams.
    /// An out-of-band data transmission mechanism may be supported.
    public static let stream = SocketType(rawValue: SOCK_STREAM, connectionless: false)
    /// Supports datagrams (connectionless, unreliable messages of a fixed
    /// maximum length).
    public static let datagram = SocketType(rawValue: SOCK_DGRAM, connectionless: true)
    /// Provides raw network protocol access.
    public static let raw = SocketType(rawValue: SOCK_RAW, connectionless: true)
    #if os(Linux)
    /// Provides a sequenced, reliable, two-way connection-based data
    /// transmission path for datagrams of fixed maximum length; a consumer is
    /// required to read an entire packet with each input system call.
    public static let sequencedPackets = SocketType(rawValue: SOCK_SEQPACKET, connectionless: false)
    /// Provides a reliable datagram layer that does not guarantee ordering.
    public static let reliableDatagram = SocketType(rawValue: SOCK_RDM, connectionless: true)
    #endif

    private init(rawValue: __socket_type, connectionless: Bool) {
        self.rawValue = OptionInt(rawValue.rawValue)
        self.connectionless = connectionless
    }
}
