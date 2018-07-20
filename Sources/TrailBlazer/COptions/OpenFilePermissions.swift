#if os(Linux)
import Glibc
#else
import Darwin
#endif

public struct OpenFilePermissions: Equatable, CustomStringConvertible {
    public let rawValue: OptionInt
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

    public static let read = OpenFilePermissions(rawValue: O_RDONLY)
    public static let write = OpenFilePermissions(rawValue: O_WRONLY)
    public static let readWrite = OpenFilePermissions(rawValue: O_RDWR)

    private init(rawValue: OptionInt) {
        self.rawValue = rawValue
    }

    public static func == (lhs: OpenFilePermissions, rhs: OpenFilePermissions) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public func contains(_ perms: OpenFilePermissions) -> Bool {
        guard self != .readWrite else { return true }

        return self == perms
    }
}
