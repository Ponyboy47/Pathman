/// A struct used to hold/manipulate permissions in a C-compatible way for the mode_t struct
public struct FilePermissions: OptionSet, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias IntegerLiteralType = OSUInt

    public private(set)var rawValue: IntegerLiteralType

    /// Read, write, and execute permissions
    public static let all: FilePermissions = 0o7
    /// Read only permissions
    public static let read: FilePermissions =  0o4
    /// Write only permissions
    public static let write: FilePermissions =  0o2
    /// Execute only permissions
    public static let execute: FilePermissions =  0o1
    /// No permissions
    public static let none: FilePermissions =  0

    /// Read and write permissions
    public static let readWrite: FilePermissions = [.read, .write]
    /// Read and execute permissions
    public static let readExecute: FilePermissions = [.read, .execute]
    /// Write and execute permissions
    public static let writeExecute: FilePermissions = [.write, .execute]
    /// All permissions
    public static let readWriteExecute: FilePermissions = .all

    // If the permissions include read permissions
    public var canRead: Bool { return contains(.read) }
    // If the permissions include write permissions
    public var canWrite: Bool { return contains(.write) }
    // If the permissions include execute permissions
    public var canExecute: Bool { return contains(.execute) }
    /// If the permissions are empty
    public var hasNone: Bool { return !(canRead || canWrite || canExecute) }

    public init(rawValue: IntegerLiteralType) {
        self.rawValue = rawValue
    }

    public init(_ perms: FilePermissions...) {
        rawValue = perms.reduce(0, { $0 | $1.rawValue })
    }

    /**
        Initialize from a Unix permissions string (3 chars 'rwx' 'r--' '-w-' '--x')
    */
    public init(_ value: String) {
        self.init(rawValue: 0)
        guard value.count == 3 else { return }

        for char in value {
            switch char {
            case "r": rawValue |= 0o4
            case "w": rawValue |= 0o2
            case "x": rawValue |= 0o1
            default: continue
            }
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

extension FilePermissions: CustomStringConvertible {
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
}
