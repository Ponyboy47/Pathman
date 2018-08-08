/// A struct for manipulating the uid, gid, and sticky bits of a file mode (mode_t in C)
public struct FileBits: OptionSet, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = OSUInt

    public let rawValue: IntegerLiteralType

    /// Whether or not the uid bit is set
    public var uid: Bool {
        return contains(.uid)
    }
    /// Whether or not the gid bit is set
    public var gid: Bool {
        return contains(.gid)
    }
    /// Whether or not the sticky bit is set
    public var sticky: Bool {
        return contains(.sticky)
    }

    /// A FileBits struct with all the bits turned on
    public static let all = FileBits(rawValue: 0o7)
    /// A FileBits struct with only the uid bit turned on
    public static let uid = FileBits(rawValue: 0o4)
    /// A FileBits struct with only the gid bit turned on
    public static let gid = FileBits(rawValue: 0o2)
    /// A FileBits struct with only the sticky bit turned on
    public static let sticky = FileBits(rawValue: 0o1)
    /// A FileBits struct with none of the bits turned on
    public static let none = FileBits(rawValue: 0)

    /// Whether or not all of the bits are off
    public var hasNone: Bool { return !(uid || gid || sticky) }

    public init(rawValue: IntegerLiteralType = 0) {
        self.rawValue = rawValue
    }

    public init(_ bits: FileBits...) {
        rawValue = bits.reduce(0, { $0 | $1.rawValue })
    }

    public init(uid: Bool = false, gid: Bool = false, sticky: Bool = false) {
        rawValue = (uid ? 4 : 0) | (gid ? 2 : 0) | (sticky ? 1 : 0)
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value)
    }
}

extension FileBits: CustomStringConvertible {
    public var description: String {
        var bits: [String] = []

        if contains(.uid) {
            bits.append("uid")
        }
        if contains(.gid) {
            bits.append("gid")
        }
        if contains(.sticky) {
            bits.append("sticky")
        }

        if bits.isEmpty {
            bits.append("none")
        }

        return "\(type(of: self))(\(bits.joined(separator: ", ")))"
    }
}
