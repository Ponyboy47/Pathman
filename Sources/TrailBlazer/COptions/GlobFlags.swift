import Cglob

public struct GlobFlags: OptionSet, ExpressibleByIntegerLiteral, CustomStringConvertible {
    public typealias IntegerLiteralType = OptionInt

    public private(set)var rawValue: IntegerLiteralType
    public var description: String {
        var flags: [String] = []

        if contains(.error) {
            flags.append("error")
        }
        if contains(.mark) {
            flags.append("mark")
        }
        if contains(.unsorted) {
            flags.append("unsorted")
        }
        if contains(.offset) {
            flags.append("offset")
        }
        if contains(.noCheck) {
            flags.append("noCheck")
        }
        if contains(.append) {
            flags.append("append")
        }
        if contains(.noEscape) {
            flags.append("noEscape")
        }
        if contains(.period) {
            flags.append("period")
        }
        if contains(.alternativeDirectoryFunctions) {
            flags.append("alternativeDirectoryFunctions")
        }
        if contains(.brace) {
            flags.append("brace")
        }
        if contains(.noMagic) {
            flags.append("noMagic")
        }
        if contains(.tilde) {
            flags.append("tilde")
        }
        if contains(.tildeCheck) {
            flags.append("tildeCheck")
        }
        if contains(.onlyDirectories) {
            flags.append("onlyDirectories")
        }

        if flags.isEmpty {
            flags.append("none")
        }

        return "\(type(of: self))(\(flags.joined(separator: ", ")), rawValue: \(rawValue))"
    }

    public static let error: GlobFlags = GlobFlags(rawValue: GLOB_ERR)
    public static let mark: GlobFlags = GlobFlags(rawValue: GLOB_MARK)
    public static let unsorted: GlobFlags = GlobFlags(rawValue: GLOB_NOSORT)
    public static let offset: GlobFlags = GlobFlags(rawValue: GLOB_DOOFFS)
    public static let noCheck: GlobFlags = GlobFlags(rawValue: GLOB_NOCHECK)
    public static let append: GlobFlags = GlobFlags(rawValue: GLOB_APPEND)
    public static let noEscape: GlobFlags = GlobFlags(rawValue: GLOB_NOESCAPE)
    public static let period: GlobFlags = GlobFlags(rawValue: GLOB_PERIOD)
    public static let alternativeDirectoryFunctions: GlobFlags = GlobFlags(rawValue: GLOB_ALTDIRFUNC)
    public static let brace: GlobFlags = GlobFlags(rawValue: GLOB_BRACE)
    public static let noMagic: GlobFlags = GlobFlags(rawValue: GLOB_NOMAGIC)
    public static let tilde: GlobFlags = GlobFlags(rawValue: GLOB_TILDE)
    public static let tildeCheck: GlobFlags = GlobFlags(rawValue: GLOB_TILDE_CHECK)
    public static let onlyDirectories: GlobFlags = GlobFlags(rawValue: GLOB_ONLYDIR)

    public init(rawValue: IntegerLiteralType) {
        self.rawValue = rawValue
    }

    public init(_ flags: GlobFlags...) {
        rawValue = flags.reduce(0, { $0 | $1.rawValue })
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value)
    }
}
