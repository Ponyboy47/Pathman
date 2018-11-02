#if os(Linux)
import let Glibc.SOCK_NONBLOCK
import let Glibc.SOCK_CLOEXEC
#endif

public struct SocketOptions: OptionSet, ExpressibleByIntegerLiteral, Hashable {
    public let rawValue: OptionInt

    #if os(Linux)
    public static let nonBlocking = SocketOptions(integerLiteral: OptionInt(SOCK_NONBLOCK.rawValue))
    public static let closeOnExec = SocketOptions(integerLiteral: OptionInt(SOCK_CLOEXEC.rawValue))
    #endif
    public static let none: SocketOptions = 0

    public init(rawValue: OptionInt) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: OptionInt) {
        self.init(rawValue: value)
    }
}
