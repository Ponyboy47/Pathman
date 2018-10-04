#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A swift wrapper around the C open path API options
public struct OpenFileFlags: OptionSet, ExpressibleByIntegerLiteral, Hashable {
    public typealias IntegerLiteralType = OptionInt
    public let rawValue: IntegerLiteralType

    /**
    Enable signal-driven I/O: generate a signal (SIGIO by default, but this can
    be changed via fcntl(2)) when input or output becomes possible on this file
    descriptor. This feature is available only for terminals, pseudoterminals,
    sockets, and (since Linux 2.6) pipes and FIFOs. See fcntl(2) for further
    details.
    NOTE: This is commented out because open(2) says, "Currently, it is not possible to enable signal-driven I/O by specifying O_ASYNC when calling open(); use fcntl(2) to enable this flag.
    */
    @available(*, unavailable, message: "Currently, it is not possible to enable signal-driven I/O by specifying O_ASYNC when calling open(); use fcntl(2) to enable this flag.")
    public static let async = OpenFileFlags(rawValue: O_ASYNC)

    /**
    The file is opened in append mode. Before each write, the file offset is
    positioned at the end of the file, as if we seeked to the end. Appending
    may lead to corrupted files on NFS filesystems if more than one process
    appends data to a file at once. This is because NFS does not support
    appending to a file, so the client kernel has to simulate it, which can't
    be done without a race condition.
    */
    public static let append = OpenFileFlags(rawValue: O_APPEND)
    /**
    Enable the close-on-exec flag for the opened path. Specifying this flag permits a program to avoid additional fcntl(2) F_SETFD operations to set the FD_CLOEXEC flag.

    NOTE: Use of this flag is essential in some multithreaded programs, because
    using a separate fcntl(2) F_SETFD operation to set the FD_CLOEXEC flag does
    not suffice to avoid race conditions where one thread opens a file
    descriptor and attempts to set its close-on-exec flag using fcntl(2) at the
    same time as another thread does a fork(2) plusexecve(2). Depending on the
    order of execution, the race may lead to the file descriptor returned by
    open() being unintentionally leaked to the program executed by the child
    process created by fork(2). (This kind of race is in principle possible for
    any system call that creates a file descriptor whose close-on-exec flag
    should be set, and various other Linux system calls provide an equivalent
    of the O_CLOEXEC flag to deal with this problem.)
    */
    public static let closeOnExec = OpenFileFlags(rawValue: O_CLOEXEC)
    /**
    If the file does not exist, it will be created. The owner (user ID) of the
    file is set to the effective user ID of the process. The group ownership
    (group ID) is set either to the effective group ID of the process or to the
    group ID of the parent directory (depending on filesystem type and mount
    options, and the mode of the parent directory; see the mount options
    bsdgroups and sysvgroups described in mount(8)).
    */
    public static let create = OpenFileFlags(rawValue: O_CREAT)
    /// If pathname is not a directory, cause the open to fail.
    public static let directory = OpenFileFlags(rawValue: O_DIRECTORY)
    /**
    Ensure that this call creates the file: if this flag is specified in
    conjunction with .create, and pathname already exists, then open() will
    fail.

    When these two flags are specified, symbolic links are not followed: if
    pathname is a symbolic link, then open() fails regardless of where the
    symbolic link points to.

    In general, the behavior of .excl is undefined if it is used without
    .create. There is one exception: on Linux 2.6 and later, .excl can be used
    without .create if pathname refers to a block device. If the block device
    is in use by the system (e.g., mounted), open() fails with the error EBUSY.

    On NFS, .excl is supported only when using NFSv3 or later on kernel 2.6 or
    later. In NFS environments where .excl support is not provided, programs
    that rely on it for performing locking tasks will contain a race condition.
    Portable programs that want to perform atomic file locking using a
    lockfile, and need to avoid reliance on NFS support for .excl, can create a
    unique file on the same filesystem (e.g., incorporating hostname and PID),
    and use link(2) to make a link to the lockfile. If link(2) returns 0, the
    lock is successful. Otherwise, use stat(2) on the unique file to check if
    its link count has increased to 2, in which case the lock is also
    successful.
    */
    public static let exclusive = OpenFileFlags(rawValue: O_EXCL)
    /**
    If pathname refers to a terminal device—see tty(4)—it will not become the
    process's controlling terminal even if the process does not have one.
    */
    public static let noCTTY = OpenFileFlags(rawValue: O_NOCTTY)
    /// If pathname is a symbolic link, then the open fails.
    public static let noFollow = OpenFileFlags(rawValue: O_NOFOLLOW)
    /**
    When possible, the file is opened in nonblocking mode. Neither the open()
    nor any subsequent operations on the file descriptor which is returned will
    cause the calling process to wait.

    NOTE: This flag has no effect for regular files and block devices; that is,
    I/O operations will (briefly) block when device activity is required,
    regardless of whether .nonBlock is set. Since .nonBlock semantics might
    eventually be implemented, applications should not depend upon blocking
    behavior when specifying this flag for regular files and block devices.

    For the handling of FIFOs (named pipes), see also fifo(7). For a discussion
    of the effect of .nonBlock in conjunction with mandatory file locks and
    with file leases, see fcntl(2).
    */
    public static let nonBlock = OpenFileFlags(rawValue: O_NONBLOCK)
    @available(*, renamed: "nonBlock")
    public static let nDelay = OpenFileFlags(rawValue: O_NDELAY)
    /**
    If the file already exists and is a regular file and the access mode allows
    writing it will be truncated to length 0. If the file is a FIFO or terminal
    device file, the .truncate flag is ignored. Otherwise, the effect of
    .truncate is unspecified.
    */
    public static let truncate = OpenFileFlags(rawValue: O_TRUNC)
    #if os(Linux)
    /**
    Write operations on the file will complete according to the requirements of
    synchronized I/O data integrity completion.

    By the time write(2) (and similar) return, the output data has been
    transferred to the underlying hardware, along with any file metadata that
    would be required to retrieve that data (i.e., as though each write(2) was
    followed by a call to fdatasync(2)).

    NOTE: For more information, see open(2) NOTES
    */
    public static let dsync = OpenFileFlags(rawValue: O_DSYNC)
    /**
    Write operations on the file will complete according to the requirements of
    synchronized I/O file integrity completion (by contrast with the
    synchronized I/O data integrity completion provided by .dsync)

    By the time write(2) (and similar) return, the output data and associated
    file metadata have been transferred to the underlying hardware (i.e., as
    though each write(2) was followed by a call to fsync(2)).
    */
    public static let sync = OpenFileFlags(rawValue: O_SYNC)

    /// All flags
    public static let all: OpenFileFlags = [.append, .closeOnExec, .create, .directory, .exclusive, .noCTTY, .noFollow, .nonBlock, .truncate, .dsync, .sync]
    #else
    /// Atomically obtain a shared lock
    public static let sharedLock = OpenFileFlags(rawValue: O_SHLOCK)
    /// Atomically obtain an exclusive lock
    public static let exclusiveLock = OpenFileFlags(rawValue: O_EXLOCK)
    /// Allow open of symlinks
    public static let symlink = OpenFileFlags(rawValue: O_SYMLINK)
    /// Descriptor requested for event notifications only
    public static let evtOnly = OpenFileFlags(rawValue: O_EVTONLY)

    /// All flags
    public static let all: OpenFileFlags = [.append, .closeOnExec, .create, .directory, .exclusive, .noCTTY, .noFollow, .nonBlock, .truncate, .sharedLock, .exclusiveLock, .symlink, .evtOnly]
    #endif

    public static let none: OpenFileFlags = []

    public init(rawValue: OptionInt) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value)
    }
}

extension OpenFileFlags: CustomStringConvertible {
    public var description: String {
        var flags: [String] = []

        if contains(.append) {
            flags.append("append")
        }
        // if contains(.async) {
        //     flags.append("async")
        // }
        if contains(.closeOnExec) {
            flags.append("closeOnExec")
        }
        if contains(.create) {
            flags.append("create")
        }
        if contains(.directory) {
            flags.append("directory")
        }
        if contains(.exclusive) {
            flags.append("exclusive")
        }
        if contains(.noCTTY) {
            flags.append("noCTTY")
        }
        if contains(.noFollow) {
            flags.append("noFollow")
        }
        if contains(.nonBlock) {
            flags.append("nonBlock")
        }
        if contains(.nDelay) {
            flags.append("nDelay")
        }
        if contains(.truncate) {
            flags.append("truncate")
        }
        #if os(Linux)
        if contains(.dsync) {
            flags.append("dsync")
        }
        if contains(.sync) {
            flags.append("sync")
        }
        #else
        if contains(.sharedLock) {
            flags.append("sharedLock")
        }
        if contains(.exclusiveLock) {
            flags.append("exclusiveLock")
        }
        if contains(.symlink) {
            flags.append("symlink")
        }
        if contains(.evtOnly) {
            flags.append("evtOnly")
        }
        #endif

        if flags.isEmpty {
            flags.append("none")
        }

        return "\(type(of: self))(\(flags.joined(separator: ", ")))"
    }
}
