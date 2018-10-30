#if os(Linux)
import let Glibc.AF_UNIX
import let Glibc.AF_LOCAL
import let Glibc.AF_INET
import let Glibc.AF_INET6
import let Glibc.AF_IPX
import let Glibc.AF_NETLINK
import let Glibc.AF_X25
import let Glibc.AF_AX25
import let Glibc.AF_ATMPVC
import let Glibc.AF_APPLETALK
import let Glibc.AF_PACKET
import let Glibc.AF_ALG
#else
import let Darwin.AF_UNIX
import let Darwin.AF_LOCAL
import let Darwin.AF_INET
import let Darwin.AF_INET6
import let Darwin.AF_IPX
import let Darwin.AF_NETLINK
import let Darwin.AF_X25
import let Darwin.AF_AX25
import let Darwin.AF_ATMPVC
import let Darwin.AF_APPLETALK
import let Darwin.AF_PACKET
import let Darwin.AF_ALG
#endif

public struct SocketDomain: Hashable {
    let rawValue: OptionInt

    /// Local communication (see unix(7))
    public static let unix = SocketDomain(rawValue: AF_UNIX)
    /// Local communication
    public static let local = SocketDomain(rawValue: AF_LOCAL)
    /// IPv4 Internet protocols (see ip(7))
    public static let ipv4 = SocketDomain(rawValue: AF_INET)
    /// IPv6 Internet protocols (see ipv6(7))
    public static let ipv6 = SocketDomain(rawValue: AF_INET6)
    /// IPX - Novell protocols
    public static let ipx = SocketDomain(rawValue: AF_IPX)
    /// Kernel user interface device (see netlink(7))
    public static let netlink = SocketDomain(rawValue: AF_NETLINK)
    /// ITU-T X.25 / ISO-8208 protocol (see x25(7))
    public static let x25 = SocketDomain(rawValue: AF_X25)
    /// Amateur radio AX.25 protocol
    public static let ax25 = SocketDomain(rawValue: AF_AX25)
    /// Access to raw ATM PVCs
    public static let atmPVC = SocketDomain(rawValue: AF_ATMPVC)
    /// AppleTalk (see ddp(7))
    public static let appleTalk = SocketDomain(rawValue: AF_APPLETALK)
    /// Low level packet interface (see packet(7))
    public static let packet = SocketDomain(rawValue: AF_PACKET)
    /// Interface to kernel crypto API
    public static let crypto = SocketDomain(rawValue: AF_ALG)

    private init(rawValue: OptionInt) {
        self.rawValue = rawValue
    }
}
