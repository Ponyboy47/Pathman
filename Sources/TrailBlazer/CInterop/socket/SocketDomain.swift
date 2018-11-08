#if os(Linux)
import let Glibc.AF_UNIX
import let Glibc.AF_LOCAL
#else
import let Darwin.PF_UNIX
import let Darwin.PF_LOCAL
#endif

public struct SocketDomain: Hashable {
    let rawValue: OptionInt

    #if os(Linux)
    /// Local communication (see unix(7))
    public static let unix = SocketDomain(rawValue: AF_UNIX)
    /// Local communication
    public static let local = SocketDomain(rawValue: AF_LOCAL)
    #else
    @available(*, deprecated, renamed: "SocketDomain.local")
    /// Host-internal protocols, deprecated, use .local
    public static let unix = SocketDomain(rawValue: PF_UNIX)
    /// Host-internal protocols, formerly called .unix
    public static let local = SocketDomain(rawValue: PF_LOCAL)
    #endif

    init(rawValue: OptionInt) {
        self.rawValue = rawValue
    }
}
