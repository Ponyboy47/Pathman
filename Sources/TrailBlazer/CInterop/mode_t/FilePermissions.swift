/// A struct used to hold/manipulate permissions in a C-compatible way for the mode_t struct
public struct FilePermissions: OptionSet, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, Hashable {
    public typealias StringLiteralType = String
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
    public var isReadable: Bool { return contains(.read) }
    // If the permissions include write permissions
    public var isWritable: Bool { return contains(.write) }
    // If the permissions include execute permissions
    public var isExecutable: Bool { return contains(.execute) }
    /// If the permissions are empty
    public var hasNone: Bool { return !(isReadable || isWritable || isExecutable) }

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
            case "x", "S", "t": rawValue |= 0o1
            default: continue
            }
        }
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value)
    }

    /// Returns the inverse FilePermissions with all bits flipped
    public static prefix func ~ (lhs: FilePermissions) -> FilePermissions {
        // NOTing flips too many bits and may cause rawValues of equivalent
        // FilePermissionss to no longer be equivalent
        return FilePermissions(rawValue: ~lhs.rawValue & FilePermissions.all.rawValue)
    }

    /// Returns a FilePermissions with the bits contained in either mode
    public static func | (lhs: FilePermissions, rhs: FilePermissions) -> FilePermissions {
        return FilePermissions(rawValue: lhs.rawValue | rhs.rawValue)
    }
    /// Returns a FilePermissions with the bits contained in either mode
    public static func | (lhs: FilePermissions, rhs: IntegerLiteralType) -> FilePermissions {
        return FilePermissions(rawValue: lhs.rawValue | rhs)
    }

    /// Sets the FilePermissions with the bits contained in either mode
    public static func |= (lhs: inout FilePermissions, rhs: FilePermissions) {
        lhs.rawValue = lhs.rawValue | rhs.rawValue
    }
    /// Sets the FilePermissions with the bits contained in either mode
    public static func |= (lhs: inout FilePermissions, rhs: IntegerLiteralType) {
        lhs.rawValue = lhs.rawValue | rhs
    }

    /// Returns a FilePermissions with only the bits contained in both modes
    public static func & (lhs: FilePermissions, rhs: FilePermissions) -> FilePermissions {
        return FilePermissions(rawValue: lhs.rawValue & rhs.rawValue)
    }
    /// Returns a FilePermissions with only the bits contained in both modes
    public static func & (lhs: FilePermissions, rhs: IntegerLiteralType) -> FilePermissions {
        return FilePermissions(rawValue: lhs.rawValue & rhs)
    }

    /// Sets the FilePermissions with only the bits contained in both modes
    public static func &= (lhs: inout FilePermissions, rhs: FilePermissions) {
        lhs.rawValue = lhs.rawValue & rhs.rawValue
    }
    /// Sets the FilePermissions with only the bits contained in both modes
    public static func &= (lhs: inout FilePermissions, rhs: IntegerLiteralType) {
        lhs.rawValue = lhs.rawValue & rhs
    }
}

extension FilePermissions: CustomStringConvertible {
    public var description: String {
        var perms: [String] = []

        if isReadable {
            perms.append("read")
        }
        if isWritable {
            perms.append("write")
        }
        if isExecutable {
            perms.append("execute")
        }

        if perms.isEmpty {
            perms.append("none")
        }

        return "\(type(of: self))(\(perms.joined(separator: ", ")))"
    }
}
