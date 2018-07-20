public struct FilePermissions: OptionSet, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias IntegerLiteralType = OSUInt

    public private(set)var rawValue: IntegerLiteralType
    public var description: String {
        var perms: [String] = []

        if canRead {
            perms.append("read")
        }
        if canWrite {
            perms.append("write")
        }
        if canExecute {
            perms.append("execute")
        }
        if perms.isEmpty {
            perms.append("none")
        }

        return "\(type(of: self))(\(perms.joined(separator: ", ")), rawValue: \(rawValue))"
    }

    public static let all: FilePermissions = 0o7
    public static let read: FilePermissions =  0o4
    public static let write: FilePermissions =  0o2
    public static let execute: FilePermissions =  0o1
    public static let none: FilePermissions =  0

    public static let readWrite: FilePermissions = [.read, .write]
    public static let readExecute: FilePermissions = [.read, .execute]
    public static let writeExecute: FilePermissions = [.write, .execute]
    public static let readWriteExecute: FilePermissions = .all

    public var canRead: Bool { return contains(.read) }
    public var canWrite: Bool { return contains(.write) }
    public var canExecute: Bool { return contains(.execute) }
    public var hasNone: Bool { return !(canRead || canWrite || canExecute) }

    public init(rawValue: IntegerLiteralType) {
        self.rawValue = rawValue
    }
 
    public init(_ perms: FilePermissions...) {
        rawValue = perms.reduce(0, { $0 | $1.rawValue })
    }

    public init(_ value: String) {
        self.init(rawValue: 0)
        guard value.count == 3 else { return }

        var value = value

        if (value.hasPrefix("r")) {
            rawValue |= 0o4
        }

        value = String(value.dropFirst())
        if (value.hasPrefix("w")) {
            rawValue |= 0o2
        }

        value = String(value.dropFirst())
        if (value.hasPrefix("x")) {
            rawValue |= 0o1
        }
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

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value)
    }
}
