#if os(Linux)
import Glibc
let cStat = Glibc.lstat
let cRename = Glibc.rename
#else
import Darwin
let cStat = Darwin.lstat
let cRename = Darwin.rename
#endif

let pathSeparator: String = "/"
fileprivate var processRoot: DirectoryPath = DirectoryPath(pathSeparator) !! "The '\(pathSeparator)' path separator is incorrect for this system."

private func getCWD() -> DirectoryPath {
    let cwd = DirectoryPath(String(cString: getcwd(nil, 0))) !! "Failed to get current working directory"
    return cwd
}

fileprivate var currentWorkingDirectory = getCWD()

/// A protocol that describes a Path type and the attributes available to it
public protocol Path: Hashable, Comparable, CustomStringConvertible, Ownable, Permissionable, Movable {
    /// The underlying path representation
    var _path: String { get set }
    /// A String representation of self
    var string: String { get }
    /// The character used to separate components of a path
    static var separator: String { get }

    /// Whether or not the path exists (or is accessible)
    var exists: Bool { get }

    init?(_ str: String)
    init?<PathType: Path>(_ path: PathType)
    init?(_ components: [String])
}

public extension Path {
    /// The character used to separate components of a path
    public static var separator: String { return pathSeparator }

    /// The root directory for the process
    public static var root: DirectoryPath {
        get { return processRoot }
        set {
            guard chroot(newValue.string) == 0 else { return }
            processRoot = newValue
        }
    }
    /// The root directory for the process
    public var root: DirectoryPath {
        get { return Self.root }
        set { Self.root = newValue }
    }

    /// The current working directory for the process
    public static var cwd: DirectoryPath {
        get { return currentWorkingDirectory }
        set {
            guard chdir(newValue.string) == 0 else { return }
            currentWorkingDirectory = newValue
        }
    }
    /// The current working directory for the process
    public var cwd: DirectoryPath {
        get { return Self.cwd }
        set { Self.cwd = newValue }
    }

    public var hashValue: Int {
        return string.hashValue
    }

    public var string: String {
        return _path
    }

    /// The different elements that make up the path
    public var components: [String] {
        var comps = string.components(separatedBy: Self.separator)
        if string.hasPrefix(Self.separator) {
            comps.insert(Self.separator, at: 0)
        }
        return comps.filter { !$0.isEmpty }
    }
    /// The last element of the path
    public var lastComponent: String? {
        return components.last
    }

    public var lastComponentWithoutExtension: String? {
        guard let last = lastComponent else { return nil }
        return String(last.prefix(last.count - (`extension`?.count ?? 0)))
    }

    /// The extension of the path
    public var `extension`: String? {
        guard let last = lastComponent else { return nil }

        let comps = last.components(separatedBy: ".")
        guard comps.count > 1 else { return nil }

        return comps.last!
    }

    /// The directy one level above the current Self's location
    public var parent: DirectoryPath {
        return DirectoryPath(components.dropLast())!
    }

    /// Whether or not the path is a directory
    public var isDirectory: Bool {
        return exists && info.type == .directory
    }

    /// Whether or not the path is a file
    public var isFile: Bool {
        return exists && info.type == .file
    }

    /// Whether or not the path is a symlink
    public var isLink: Bool {
        return exists && StatInfo(self, options: .getLinkInfo).type == .link
    }

    /// Whether or not the path exists (or is accessible)
    public var exists: Bool {
        var s: stat
        #if os(Linux)
        s = Glibc.stat()
        #else
        s = Darwin.stat()
        #endif
        return cStat(string, &s) == 0
    }

    public var description: String {
        return "\(Swift.type(of: self))(\(string))"
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.string == rhs.string
    }
    public static func == <PathType: Path>(lhs: Self, rhs: PathType) -> Bool {
        return lhs.string == rhs.string
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.string < rhs.string
    }
    public static func < <PathType: Path>(lhs: Self, rhs: PathType) -> Bool {
        return lhs.string < rhs.string
    }

    public func change(owner uid: uid_t = ~0, group gid: gid_t = ~0) throws {
        guard exists else { return }

        guard chown(string, uid, gid) == 0 else {
            throw ChangeOwnershipError.getError()
        }
    }

    public func change(permissions: FileMode) throws {
        guard exists else { return }

        guard chmod(string, permissions.rawValue) == 0 else {
            throw ChangePermissionsError.getError()
        }
    }

    public mutating func move<PathType: Path>(to newPath: PathType) throws {
        if !(newPath is GenericPath) {
            guard self is PathType else {
                throw MoveError.moveToDifferentPathType
            }
        }

        guard cRename(string, newPath.string) == 0 else {
            throw MoveError.getError()
        }

        _path = newPath.string
    }
}
