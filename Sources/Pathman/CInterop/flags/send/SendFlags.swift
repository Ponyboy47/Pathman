#if os(Linux)
import let Glibc.MSG_CONFIRM
import let Glibc.MSG_DONTROUTE
import let Glibc.MSG_DONTWAIT
import let Glibc.MSG_MORE
import let Glibc.MSG_NOSIGNAL
import let Glibc.MSG_OOB
#else
import let Darwin.MSG_DONTROUTE
import let Darwin.MSG_DONTWAIT
import let Darwin.MSG_OOB
#endif

public struct SendFlags: OptionSet, ExpressibleByIntegerLiteral, Hashable {
    public let rawValue: OptionInt

    #if os(Linux)
    /**
     Tell the link layer that forward progress happened: you got a successful
     reply from the other side. If the link layer doesn't get this it will
     regularly reprobe the neighbor (e.g., via a unicast ARP). Valid only on
     datagram sockets.
     */
    public static let confirm = SendFlags(integerLiteral: MSG_CONFIRM)
    /**
     The caller has more data to send. This flag is used with TCP sockets to
     obtain the same effect as the TCP_CORK socket option (see tcp(7)), with the
     difference that this flag can be set on a per-call basis.

     Since  Linux  2.6, this flag is also supported for UDP sockets, and informs
     the kernel to package all of the data sent in calls with this flag set into
     a single datagram which is transmitted only when a call is performed that
     does not specifythis flag. (See also the UDP_CORK socket option described
     in udp(7).)
     */
    public static let more = SendFlags(integerLiteral: MSG_MORE)
    /**
     Don't  generate a SIGPIPE signal if the peer on a stream-oriented socket
     has closed the connection. The EPIPE error isstill returned. This provides
     similar behavior to using sigaction(2) to ignore SIGPIPE, but, whereas
     .noSignal is a per-call feature, ignoring SIGPIPE sets a process attribute
     that affects all threads in the process.
     */
    public static let noSignal = SendFlags(integerLiteral: MSG_NOSIGNAL)
    #endif

    /**
     Don't use a gateway to send out the packet, send to hosts only on directly
     connected networks. This is usually used only by diagnostic or routing
     programs. This is defined only for protocol families that route; packet
     sockets don't.
     */
    public static let dontRoute = SendFlags(integerLiteral: MSG_DONTROUTE)
    /**
     Enables nonblocking operation; if the operation would block, .wouldBlock is
     returned. This provides similar behavior to setting the .nonBlock flag (via
     the fcntl(2) F_SETFL operation), but differs in that .dontWait is a
     per-call option, whereas .nonBlock is a setting on the open file description
     (see open(2)), which will affect all threads in the calling process and as
     well as other processes that hold file descriptors referring to the same
     open file description.
     */
    public static let dontWait = SendFlags(integerLiteral: MSG_DONTWAIT)
    /**
     Sends out-of-band data on sockets that support this notion (e.g., of type
     SOCK_STREAM); the underlying protocol must also support out-of-band data.
     */
    public static let outOfBound = SendFlags(integerLiteral: MSG_OOB)

    public static let none: SendFlags = 0

    public init(rawValue: OptionInt) {
        self.rawValue = rawValue
    }

    #if os(Linux)
    public init(integerLiteral value: Int) {
        self.init(rawValue: OptionInt(value))
    }

    #else
    public init(integerLiteral value: OptionInt) {
        self.init(rawValue: value)
    }
    #endif
}
