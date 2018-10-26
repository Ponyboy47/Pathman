#if os(Linux)
import Glibc
#else
import Darwin
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

    public init?(number: Int) {
        guard let protoent = getprotobynumber(OptionInt(number)) else { return nil }
        self.init(protoent)
    }
}
