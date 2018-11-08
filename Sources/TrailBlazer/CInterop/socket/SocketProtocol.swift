#if os(Linux)
import let Glibc.IPPROTO_TCP
import let Glibc.IPPROTO_UDP
import struct Glibc.protoent
import func Glibc.getprotobyname
import func Glibc.getprotobynumber
#else
import let Darwin.IPPROTO_TCP
import let Darwin.IPPROTO_UDP
import struct Darwin.protoent
import func Darwin.getprotobyname
import func Darwin.getprotobynumber
#endif

public struct SocketProtocol: Hashable {
    let name: String
    let aliases: [String]
    let rawValue: OptionInt

    public static let tcp = SocketProtocol(number: IPPROTO_TCP)!
    public static let udp = SocketProtocol(number: IPPROTO_UDP)!

    private init(_ protoent: UnsafeMutablePointer<protoent>) {
        name = String(cString: protoent.pointee.p_name)

        var aliases: [String] = []
        while let alias = protoent.pointee.p_aliases.pointee {
            aliases.append(String(cString: alias))
            protoent.pointee.p_aliases = protoent.pointee.p_aliases.advanced(by: 1)
        }
        self.aliases = aliases

        rawValue = protoent.pointee.p_proto
    }

    public init?(name: String) {
        guard let protoent = getprotobyname(name) else { return nil }
        self.init(protoent)
    }

    #if os(Linux)
    public init?(number: Int) {
        guard let protoent = getprotobynumber(OptionInt(number)) else { return nil }
        self.init(protoent)
    }
    #else
    public init?(number: Int32) {
        guard let protoent = getprotobynumber(number) else { return nil }
        self.init(protoent)
    }
    #endif
}
