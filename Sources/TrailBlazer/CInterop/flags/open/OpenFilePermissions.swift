#if os(Linux)
import let Glibc.O_RDONLY
import let Glibc.O_RDWR
import let Glibc.O_WRONLY
#else
import let Darwin.O_RDONLY
import let Darwin.O_RDWR
import let Darwin.O_WRONLY
#endif

public struct OpenFilePermissions: Equatable, ExpressibleByIntegerLiteral, Hashable {
    public typealias IntegerLiteralType = OptionInt
    public let rawValue: IntegerLiteralType

    /// Allow read-only access when opening a file
    public static let read = OpenFilePermissions(rawValue: O_RDONLY) // == 0
    /// Allow write-only access when opening a file
    public static let write = OpenFilePermissions(rawValue: O_WRONLY) // == 1
    /// Allow both read and write access when opening a file
    public static let readWrite = OpenFilePermissions(rawValue: O_RDWR) // == 2
    /// All possible permissions (read and write)
    public static let all: OpenFilePermissions = .readWrite

    public static let none: OpenFilePermissions = -1

    public var mayRead: Bool { return contains(.read) }
    public var mayWrite: Bool { return contains(.write) }

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
        return self == .readWrite || self == perms
    }
}

extension OpenFilePermissions: CustomStringConvertible {
    public var description: String {
        var permissions: [String] = []
        if mayRead {
            permissions.append("read")
        }
        if mayWrite {
            permissions.append("write")
        }
        if permissions.isEmpty {
            permissions.append("none")
        }

        return "\(type(of: self))(\(permissions.joined(separator: ", ")))"
    }
}
