/// A swift wrapper around the C mode_t type, which is used to hold/manipulate information about a Path's permissions
public struct FileMode: OptionSet, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, Hashable {
    public typealias IntegerLiteralType = OSUInt
    public typealias StringLiteralType = String

    public private(set) var rawValue: IntegerLiteralType

    /// The uid, gid, and sticky bits
    public var bits: FileBits {
        get { return FileBits(rawValue: (rawValue >> 9) & 0o7) }
        set {
            rawValue &= 0o0777
            rawValue |= newValue.rawValue << 9
        }
    }
    /// The permissions for the owner of the Path
    public var owner: FilePermissions {
        get { return FilePermissions(rawValue: (rawValue >> 6) & 0o7) }
        set {
            rawValue &= 0o7077
            rawValue |= newValue.rawValue << 6
        }
    }
    /// The permissions for members of the group of the Path
    public var group: FilePermissions {
        get { return FilePermissions(rawValue: (rawValue >> 3) & 0o7) }
        set {
            rawValue &= 0o7707
            rawValue |= newValue.rawValue << 3
        }
    }
    /// The permissions for others accessing the Path
    public var others: FilePermissions {
        get { return FilePermissions(rawValue: rawValue & 0o7) }
        set {
            rawValue &= 0o7770
            rawValue |= newValue.rawValue
        }
    }

    /// A FileMode with all permissions and all bits on
    public static let all: FileMode = 0o7777
    /// A FileMode with all permissions and no bits on
    public static let allPermissions: FileMode = 0o0777
    /// A FileMode with no permissions and all bits on
    public static let allBits: FileMode = 0o7000
    /// A FileMode with no permissions and no bits
    public static let none: FileMode = 0

    public init(rawValue: IntegerLiteralType) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value)
    }

    private static let validStringSizes = 9...11

    private static func calcFileBit(from index: Int) -> FileBits {
        return (index / 3) == 0 ? .uid : (index / 3) == 1 ? .gid : .sticky
    }

    /**
        Initialize from a Unix permissions string (-rwxrwxrwx)
    */
    public init(_ value: String) {
        self.init(rawValue: 0)
        // 9 characters give us 3 sections of 3 (user, group, other)
        // 10 characters is what linux uses where the first character is either
        //   a 'd' for directory or a '-'
        // 11 characters are sometimes present on macOS where the first
        //   character is like linux, but the last character is either empty, a
        //   '+', or an '@'
        guard FileMode.validStringSizes.contains(value.count) else { return }

        var startIndex = value.startIndex
        var endIndex = value.endIndex
        if value.count >= 10 {
            startIndex = value.index(after: startIndex)
        }
        if value.count == 11 {
            endIndex = value.index(before: endIndex)
        }
        let sub = value[startIndex..<endIndex]

        var raw: IntegerLiteralType = 0
        for (index, char) in sub.enumerated() {
            if index % 3 == 0 {
                rawValue |= raw << (9 - index)
                raw = 0
            }

            switch char {
            case "r": raw |= 0o4
            case "w": raw |= 0o2
            case "T":
                rawValue |= FileMode.calcFileBit(from: index).rawValue << 9
            case "S", "t":
                rawValue |= FileMode.calcFileBit(from: index).rawValue << 9
                fallthrough
            case "x": raw |= 0o1
            default: continue
            }
        }
        rawValue |= raw
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }

    private init(owner: IntegerLiteralType = 0,
                 group: IntegerLiteralType = 0,
                 others: IntegerLiteralType = 0,
                 bits: IntegerLiteralType = 0) {
        var rawValue: IntegerLiteralType = bits << 9
        rawValue |= (owner << 6)
        rawValue |= (group << 3)
        rawValue |= others
        self.init(rawValue: rawValue)
    }

    /**
        Initializes a FileMode with the specified permissions and bits

        - Parameter owner: The permissions for the owner of the path
        - Parameter group: The permissions for members of the group of the path
        - Parameter others: The permissions for everyone else
        - Parameter bits: The uid, gid, and sticky bits

        NOTE: The default for each parameter is .none
    */
    public init(owner: FilePermissions = .none,
                group: FilePermissions = .none,
                others: FilePermissions = .none,
                bits: FileBits = .none) {
        self.init(owner: owner.rawValue, group: group.rawValue, others: others.rawValue, bits: bits.rawValue)
    }

    /**
        Initializes a FileMode with the specified permissions and bits

        - Parameter owner: The permissions for the owner of the path
        - Parameter group: The permissions for members of the group of the path
        - Parameter others: The permissions for everyone else
        - Parameter bits: The uid, gid, and sticky bits
    */
    public static func owner(_ owner: FilePermissions,
                             group: FilePermissions = .none,
                             others: FilePermissions = .none,
                             bits: FileBits = .none) -> FileMode {
        return FileMode(owner: owner.rawValue, group: group.rawValue, others: others.rawValue, bits: bits.rawValue)
    }
    /**
        Initializes a FileMode with the specified permissions and bits

        - Parameter group: The permissions for members of the group of the path
        - Parameter owner: The permissions for the owner of the path
        - Parameter others: The permissions for everyone else
        - Parameter bits: The uid, gid, and sticky bits
    */
    public static func group(_ group: FilePermissions,
                             owner: FilePermissions = .none,
                             others: FilePermissions = .none,
                             bits: FileBits = .none) -> FileMode {
        return FileMode(owner: owner.rawValue, group: group.rawValue, others: others.rawValue, bits: bits.rawValue)
    }
    /**
        Initializes a FileMode with the specified permissions and bits

        - Parameter others: The permissions for everyone else
        - Parameter owner: The permissions for the owner of the path
        - Parameter group: The permissions for members of the group of the path
        - Parameter bits: The uid, gid, and sticky bits
    */
    public static func others(_ others: FilePermissions,
                              owner: FilePermissions = .none,
                              group: FilePermissions = .none,
                              bits: FileBits = .none) -> FileMode {
        return FileMode(owner: owner.rawValue, group: group.rawValue, others: others.rawValue, bits: bits.rawValue)
    }
    /**
        Initializes a FileMode with the specified permissions and bits

        - Parameter perms: The permissions for the owner and members of the group of the path
        - Parameter others: The permissions for everyone else
        - Parameter bits: The uid, gid, and sticky bits
    */
    public static func ownerGroup(_ perms: FilePermissions,
                                  others: FilePermissions = .none,
                                  bits: FileBits = .none) -> FileMode {
        return FileMode(owner: perms.rawValue, group: perms.rawValue, others: others.rawValue, bits: bits.rawValue)
    }
    /**
        Initializes a FileMode with the specified permissions and bits

        - Parameter perms: The permissions for the owner of the path and everyone else
        - Parameter group: The permissions for members of the group of the path
        - Parameter bits: The uid, gid, and sticky bits
    */
    public static func ownerOthers(_ perms: FilePermissions,
                                   group: FilePermissions = .none,
                                   bits: FileBits = .none) -> FileMode {
        return FileMode(owner: perms.rawValue, group: group.rawValue, others: perms.rawValue, bits: bits.rawValue)
    }
    /**
        Initializes a FileMode with the specified permissions and bits

        - Parameter group: The permissions for members of the group of the path and everyone else
        - Parameter owner: The permissions for the owner of the path
        - Parameter bits: The uid, gid, and sticky bits
    */
    public static func groupOthers(_ perms: FilePermissions,
                                   owner: FilePermissions = .none,
                                   bits: FileBits = .none) -> FileMode {
        return FileMode(owner: owner.rawValue, group: perms.rawValue, others: perms.rawValue, bits: bits.rawValue)
    }
    /**
        Initializes a FileMode with the specified permissions and bits

        - Parameter perms: The permissions for everyone who accesses the path
        - Parameter bits: The uid, gid, and sticky bits
    */
    public static func ownerGroupOthers(_ perms: FilePermissions, bits: FileBits = .none) -> FileMode {
        return FileMode(owner: perms.rawValue, group: perms.rawValue, others: perms.rawValue, bits: bits.rawValue)
    }

    /**
    Determine if the current FileMode will be reduced by the process's umask

    - Returns: true if the FileMode is permitted by the umask
    */
    public func checkAgainstUMask() -> Bool {
        return self == unmasked()
    }

    /**
        Checks the FileMode against the umask (see umask(2))

        - Returns: The FileMode after disabling bits from the umask
    */
    public func unmasked() -> FileMode {
        return ~TrailBlazer.umask & self
    }

    /// Mutates self to be the FileMode after disabling bits from the umask
    public mutating func unmask() {
        self &= ~TrailBlazer.umask
    }

    /// Returns the inverse FileMode with all bits flipped
    public static prefix func ~ (lhs: FileMode) -> FileMode {
        // NOTing flips too many bits and may cause rawValues of equivalent
        // FileModes to no longer be equivalent
        return FileMode(rawValue: ~lhs.rawValue & FileMode.all.rawValue)
    }

    /// Returns a FileMode with the bits contained in either mode
    public static func | (lhs: FileMode, rhs: FileMode) -> FileMode {
        return FileMode(rawValue: lhs.rawValue | rhs.rawValue)
    }
    /// Returns a FileMode with the bits contained in either mode
    public static func | (lhs: FileMode, rhs: IntegerLiteralType) -> FileMode {
        return FileMode(rawValue: lhs.rawValue | rhs)
    }

    /// Sets the FileMode with the bits contained in either mode
    public static func |= (lhs: inout FileMode, rhs: FileMode) {
        lhs.rawValue = lhs.rawValue | rhs.rawValue
    }
    /// Sets the FileMode with the bits contained in either mode
    public static func |= (lhs: inout FileMode, rhs: IntegerLiteralType) {
        lhs.rawValue = lhs.rawValue | rhs
    }

    /// Returns a FileMode with only the bits contained in both modes
    public static func & (lhs: FileMode, rhs: FileMode) -> FileMode {
        return FileMode(rawValue: lhs.rawValue & rhs.rawValue)
    }
    /// Returns a FileMode with only the bits contained in both modes
    public static func & (lhs: FileMode, rhs: IntegerLiteralType) -> FileMode {
        return FileMode(rawValue: lhs.rawValue & rhs)
    }

    /// Sets the FileMode with only the bits contained in both modes
    public static func &= (lhs: inout FileMode, rhs: FileMode) {
        lhs.rawValue = lhs.rawValue & rhs.rawValue
    }
    /// Sets the FileMode with only the bits contained in both modes
    public static func &= (lhs: inout FileMode, rhs: IntegerLiteralType) {
        lhs.rawValue = lhs.rawValue & rhs
    }
}

extension FileMode: CustomStringConvertible {
    public var description: String {
        return "\(type(of: self))(owner: \(owner), group: \(group), others: \(others), bits: \(bits))"
    }
}
