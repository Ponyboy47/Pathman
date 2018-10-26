#if os(Linux)
import Glibc
#else
import Darwin
#endif

public struct SocketOptions: OptionSet, ExpressibleByIntegerLiteral, Hashable {
    public let rawValue: OptionInt

    public static let nonBlocking = SocketOptions(integerLiteral: OptionInt(SOCK_NONBLOCK.rawValue))
    public static let closeOnExec = SocketOptions(integerLiteral: OptionInt(SOCK_CLOEXEC.rawValue))

    public init(rawValue: OptionInt) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: OptionInt) {
        self.init(rawValue: value)
    }
}
