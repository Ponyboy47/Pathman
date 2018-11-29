#if os(Linux)
import let Glibc.MSG_CMSG_CLOEXEC
import let Glibc.MSG_DONTWAIT
import let Glibc.MSG_OOB
import let Glibc.MSG_PEEK
import let Glibc.MSG_TRUNC
import let Glibc.MSG_WAITALL
#else
import let Darwin.MSG_DONTWAIT
import let Darwin.MSG_OOB
import let Darwin.MSG_PEEK
import let Darwin.MSG_TRUNC
import let Darwin.MSG_WAITALL
#endif

public struct ReceiveFlags: OptionSet, ExpressibleByIntegerLiteral, Hashable {
    public let rawValue: OptionInt

    #if os(Linux)
    /**
    Set the close-on-exec flag for the file descriptor received via a UNIX
    domain file descriptor using the SCM_RIGHTS operation (described in
    unix(7)).  This flag is useful for the same reasons as the .closeOnExec
    flag of open(2).
    */
    public static let closeOnExec = ReceiveFlags(integerLiteral: MSG_CMSG_CLOEXEC)
    #endif

    /**
    Enables  nonblocking  operation; if the operation would block, the call
    fails with the error .wouldBlock. This provides similar behavior to setting
    the .nonBlock flag (via the fcntl(2) F_SETFL operation), but differs in
    that .dontWait is a per-call option, whereas .nonBlock is a setting on the
    open file description (see open(2)), which will affect all threads in the
    calling process and as well as other processes that hold file descriptors
    referring to the same open file description.
    */
    public static let dontWait = ReceiveFlags(integerLiteral: MSG_DONTWAIT)
    /**
    This flag requests receipt of out-of-band data that would not be received
    in the normal data stream. Some protocols place expedited data at the head
    of the normal data queue, and thus this flag cannot be used with such
    protocols.
    */
    public static let outOfBound = ReceiveFlags(integerLiteral: MSG_OOB)
    /**
    This flag causes the receive operation to return data from the beginning of
    the receive queue without removing that data from the queue. Thus, a
    subsequent receive call will return the same data.
    */
    public static let peek = ReceiveFlags(integerLiteral: MSG_PEEK)
    /**
    Return the real length of the packet or datagram, even when it was longer
    than the passed buffer.
    */
    public static let truncate = ReceiveFlags(integerLiteral: MSG_TRUNC)
    /**
    This flag requests that the operation block until the full request is
    satisfied. However, the call may still return less data than requested if a
    signal is caught, an error or disconnect occurs, or the next data to be
    received is of a different type than that returned. This flag has no effect
    for datagram sockets.
    */
    public static let waitAll = ReceiveFlags(integerLiteral: MSG_WAITALL)

    public static let none: ReceiveFlags = 0

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
