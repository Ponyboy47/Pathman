public struct FileBits: OptionSet, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = OSUInt

    public let rawValue: IntegerLiteralType

    public var uid: Bool {
        return contains(.uid)
    }
    public var gid: Bool {
        return contains(.gid)
    }
    public var sticky: Bool {
        return contains(.sticky)
    }

    public static let all = FileBits(rawValue: 0o7)
    public static let uid = FileBits(rawValue: 0o4)
    public static let gid = FileBits(rawValue: 0o2)
    public static let sticky = FileBits(rawValue: 0o1)
    public static let none = FileBits(rawValue: 0)

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
