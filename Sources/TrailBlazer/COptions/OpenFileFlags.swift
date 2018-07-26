#if os(Linux)
import Glibc
#else
import Darwin
#endif

public struct OpenFileFlags: OptionSet {
    public let rawValue: OptionInt

    public static let append = OpenFileFlags(rawValue: O_APPEND)
    public static let async = OpenFileFlags(rawValue: O_ASYNC)
    public static let closeOnExec = OpenFileFlags(rawValue: O_CLOEXEC)
    public static let create = OpenFileFlags(rawValue: O_CREAT)
    public static let directory = OpenFileFlags(rawValue: O_DIRECTORY)
    public static let excl = OpenFileFlags(rawValue: O_EXCL)
    public static let noCTTY = OpenFileFlags(rawValue: O_NOCTTY)
    public static let noFollow = OpenFileFlags(rawValue: O_NOFOLLOW)
    public static let nonBlock = OpenFileFlags(rawValue: O_NONBLOCK)
    public static let nDelay = OpenFileFlags(rawValue: O_NDELAY)
    public static let truncate = OpenFileFlags(rawValue: O_TRUNC)
    #if os(Linux)
    public static let dsync = OpenFileFlags(rawValue: O_DSYNC)
    public static let sync = OpenFileFlags(rawValue: O_SYNC)
    #else
    public static let sharedLock = OpenFileFlags(rawValue: O_SHLOCK)
    public static let exclusiveLock = OpenFileFlags(rawValue: O_EXLOCK)
    public static let symlink = OpenFileFlags(rawValue: O_SYMLINK)
    public static let evtOnly = OpenFileFlags(rawValue: O_EVTONLY)
    #endif

    public init(rawValue: OptionInt) {
        self.rawValue = rawValue
    }
}

extension OpenFileFlags: CustomStringConvertible {
    public var description: String {
        var flags: [String] = []

        if contains(.append) {
            flags.append("append")
        }
        if contains(.async) {
            flags.append("async")
        }
        if contains(.closeOnExec) {
            flags.append("closeOnExec")
        }
        if contains(.create) {
            flags.append("create")
        }
        if contains(.directory) {
            flags.append("directory")
        }
        if contains(.excl) {
            flags.append("excl")
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

        return "\(type(of: self))(\(flags.joined(separator: ", ")), rawValue: \(rawValue))"
    }
}
