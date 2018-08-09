#if os(Linux)
import Glibc
#else
import Darwin
#endif

public struct OpenFilePermissions: Equatable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = OptionInt
    public let rawValue: IntegerLiteralType

    /// Allow read-only access when opening a file
    public static let read = OpenFilePermissions(rawValue: O_RDONLY)
    /// Allow write-only access when opening a file
    public static let write = OpenFilePermissions(rawValue: O_WRONLY)
    /// Allow both read and write access when opening a file
    public static let readWrite = OpenFilePermissions(rawValue: O_RDWR)
    /// All possible permissions (read and write)
    public static let all: OpenFilePermissions = .readWrite

    public init(rawValue: IntegerLiteralType) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value)
    }

    public static func == (lhs: OpenFilePermissions, rhs: OpenFilePermissions) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public func contains(_ perms: OpenFilePermissions) -> Bool {
        return (rawValue & perms.rawValue) == perms.rawValue
    }
}

extension OpenFilePermissions: CustomStringConvertible {
    public var description: String {
        if self == .read {
            return "\(type(of: self))(read)"
        } else if self == .write {
            return "\(type(of: self))(write)"
        } else if self == .readWrite {
            return "\(type(of: self))(readWrite)"
        } else {
            return "\(type(of: self))(unknown)"
        }
    }
}
