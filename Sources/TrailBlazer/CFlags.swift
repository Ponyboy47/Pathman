#if os(Linux)
import Glibc
#else
import Darwin
#endif

public struct OpenFilePermissions: OptionSet {
    public let rawValue: Int32

    public static let read = OpenFilePermissions(rawValue: O_RDONLY)
    public static let write = OpenFilePermissions(rawValue: O_WRONLY)
    public static let readAndWrite = OpenFilePermissions(rawValue: O_RDWR)

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
}
public struct OpenFileFlags: OptionSet {
    public let rawValue: Int32

    public static let append = OpenFileFlags(rawValue: O_APPEND)
    public static let async = OpenFileFlags(rawValue: O_ASYNC)
    public static let closeOnExec = OpenFileFlags(rawValue: O_CLOEXEC)
    public static let create = OpenFileFlags(rawValue: O_CREAT)
    public static let directory = OpenFileFlags(rawValue: O_DIRECTORY)
    public static let dsync = OpenFileFlags(rawValue: O_DSYNC)
    public static let excl = OpenFileFlags(rawValue: O_EXCL)
    public static let noCTTY = OpenFileFlags(rawValue: O_NOCTTY)
    public static let noFollow = OpenFileFlags(rawValue: O_NOFOLLOW)
    public static let nonBlock = OpenFileFlags(rawValue: O_NONBLOCK)
    public static let nDelay = OpenFileFlags(rawValue: O_NDELAY)
    public static let sync = OpenFileFlags(rawValue: O_SYNC)
    public static let truncate = OpenFileFlags(rawValue: O_TRUNC)

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
}

public struct FilePermissions: OptionSet, ExpressibleByStringLiteral {
    public let rawValue: UInt32
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

    public static let read = FilePermissions(rawValue: 0o4)
    public static let write = FilePermissions(rawValue: 0o2)
    public static let execute = FilePermissions(rawValue: 0o1)

    public var hasNone: Bool { return !(contains(.read) || contains(.write) || contains(.execute)) }

    public init(rawValue: UInt32 = 0) {
        self.rawValue = rawValue
    }

    public init(_ perms: FilePermissions...) {
        rawValue = perms.reduce(0, { $0 | $1.rawValue })
    }

    public init(_ value: String) {
        guard value.count == 3 else { self.init(); return }

        var value = value
        var perms: UInt32 = 0

        if (value.hasPrefix("r")) {
            perms |= 0o4
        }

        value = String(value.dropFirst())
        if (value.hasPrefix("w")) {
            perms |= 0o2
        }

        value = String(value.dropFirst())
        if (value.hasPrefix("x")) {
            perms |= 0o1
        }
        self.init(rawValue: perms)
    }

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

public struct FileMode: OptionSet {
    public let rawValue: UInt32

    public var owner: FilePermissions {
        return FilePermissions(rawValue: rawValue >> 6)
    }
    public var group: FilePermissions {
        return FilePermissions(rawValue: rawValue >> 3)
    }
    public var others: FilePermissions {
        return FilePermissions(rawValue: rawValue)
    }

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    private init(owner: UInt32 = 0, group: UInt32 = 0, others: UInt32 = 0) {
        self.init(rawValue: (owner << 6) | (group << 3) | others)
    }
    public init(owner: FilePermissions = [], group: FilePermissions = [], others: FilePermissions = []) {
        self.init(owner: owner.rawValue, group: group.rawValue, others: others.rawValue)
    }

    public static func owner(_ perms: FilePermissions...) -> FileMode {
        return FileMode(owner: perms.reduce(0, { $0 | $1.rawValue }))
    }
    public static func group(_ perms: FilePermissions...) -> FileMode {
        return FileMode(group: perms.reduce(0, { $0 | $1.rawValue }))
    }
    public static func others(_ perms: FilePermissions...) -> FileMode {
        return FileMode(others: perms.reduce(0, { $0 | $1.rawValue }))
    }
    public static func ownerGroup(_ perms: FilePermissions...) -> FileMode {
        let raw = perms.reduce(0, { $0 | $1.rawValue })
        return FileMode(owner: raw, group: raw)
    }
    public static func ownerOthers(_ perms: FilePermissions...) -> FileMode {
        let raw = perms.reduce(0, { $0 | $1.rawValue })
        return FileMode(owner: raw, others: raw)
    }
    public static func groupOthers(_ perms: FilePermissions...) -> FileMode {
        let raw = perms.reduce(0, { $0 | $1.rawValue })
        return FileMode(group: raw, others: raw)
    }
    public static func ownerGroupOthers(_ perms: FilePermissions...) -> FileMode {
        let raw = perms.reduce(0, { $0 | $1.rawValue })
        return FileMode(owner: raw, group: raw, others: raw)
    }
}
