public struct FileMode: OptionSet, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = OSUInt

    public private(set)var rawValue: IntegerLiteralType

    public var bits: FileBits {
        get { return FileBits(rawValue: (rawValue >> 9) & 0o7) }
        set {
            rawValue &= 0o0777
            rawValue |= newValue.rawValue << 9
        }
    }
    public var owner: FilePermissions {
        get { return FilePermissions(rawValue: (rawValue >> 6) & 0o7) }
        set {
            rawValue &= 0o7077
            rawValue |= newValue.rawValue << 6
        }
    }
    public var group: FilePermissions {
        get { return FilePermissions(rawValue: (rawValue >> 3) & 0o7) }
        set {
            rawValue &= 0o7707
            rawValue |= newValue.rawValue << 3
        }
    }
    public var others: FilePermissions {
        get { return FilePermissions(rawValue: rawValue & 0o7) }
        set {
            rawValue &= 0o7770
            rawValue |= newValue.rawValue
        }
    }

    public static let all: FileMode = FileMode(rawValue: 0o7777)
    public static let allPermissions: FileMode = FileMode(rawValue: 0o0777)
    public static let allBits: FileMode = FileMode(rawValue: 0o7000)

    public init(rawValue: IntegerLiteralType) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value)
    }

    private init(owner: IntegerLiteralType = 0, group: IntegerLiteralType = 0, others: IntegerLiteralType = 0, bits: IntegerLiteralType = 0) {
        var rawValue: IntegerLiteralType = bits << 9
        rawValue |= (owner << 6)
        rawValue |= (group << 3)
        rawValue |= others
        self.init(rawValue: rawValue)
    }

    public init(owner: FilePermissions = .none, group: FilePermissions = .none, others: FilePermissions = .none, bits: FileBits = .none) {
        self.init(owner: owner.rawValue, group: group.rawValue, others: others.rawValue, bits: bits.rawValue)
    }

    public static func owner(_ owner: FilePermissions, group: FilePermissions = .none, others: FilePermissions = .none, bits: FileBits = .none) -> FileMode {
        return FileMode(owner: owner.rawValue, group: group.rawValue, others: others.rawValue, bits: bits.rawValue)
    }
    public static func group(_ group: FilePermissions, owner: FilePermissions = .none, others: FilePermissions = .none, bits: FileBits = .none) -> FileMode {
        return FileMode(owner: owner.rawValue, group: group.rawValue, others: others.rawValue, bits: bits.rawValue)
    }
    public static func others(_ others: FilePermissions, owner: FilePermissions = .none, group: FilePermissions = .none, bits: FileBits = .none) -> FileMode {
        return FileMode(owner: owner.rawValue, group: group.rawValue, others: others.rawValue, bits: bits.rawValue)
    }
    public static func ownerGroup(_ perms: FilePermissions, others: FilePermissions = .none, bits: FileBits = .none) -> FileMode {
        return FileMode(owner: perms.rawValue, group: perms.rawValue, others: others.rawValue, bits: bits.rawValue)
    }
    public static func ownerOthers(_ perms: FilePermissions, group: FilePermissions = .none, bits: FileBits = .none) -> FileMode {
        return FileMode(owner: perms.rawValue, group: group.rawValue, others: perms.rawValue, bits: bits.rawValue)
    }
    public static func groupOthers(_ perms: FilePermissions, owner: FilePermissions = .none, bits: FileBits = .none) -> FileMode {
        return FileMode(owner: owner.rawValue, group: perms.rawValue, others: perms.rawValue, bits: bits.rawValue)
    }
    public static func ownerGroupOthers(_ perms: FilePermissions, bits: FileBits = .none) -> FileMode {
        return FileMode(owner: perms.rawValue, group: perms.rawValue, others: perms.rawValue, bits: bits.rawValue)
    }

    public func checkAgainstUMask() -> FileMode {
        return FileMode(rawValue: (~umask.rawValue) & rawValue)
    }
}

extension FileMode: CustomStringConvertible {
    public var description: String {
        var str = "\(type(of: self))(owner: \(owner), group: \(group), others: \(others)"

        #if os(Linux)
        str += ", uid: \(bits.uid), gid: \(bits.gid), sticky: \(bits.sticky)"
        #endif

        str += ")"

        return str
    }
}
