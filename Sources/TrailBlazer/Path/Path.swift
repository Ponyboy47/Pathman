#if os(Linux)
import Glibc
let cStat = Glibc.lstat
#else
import Darwin
let cStat = Darwin.lstat
#endif

let pathSeparator: String = "/"
fileprivate var processRoot: DirectoryPath = DirectoryPath(pathSeparator) !! "The '\(pathSeparator)' path separator is incorrect for this system."

private func getCWD() -> DirectoryPath {
    let cwd = DirectoryPath(String(cString: getcwd(nil, 0))) !! "Failed to get current working directory"
    return cwd
}

fileprivate var currentWorkingDirectory = getCWD()

// Used internally to ensure only this framework can modify the path
protocol _Path: Path {
    /// The underlying path representation
    var path: String { get set }
}

/// A protocol that describes a Path type and the attributes available to it
public protocol Path: Hashable, Comparable, CustomStringConvertible, Ownable, Permissionable {
    /// The underlying path representation
    var path: String { get }
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
        return path.hashValue
    }

    public var string: String {
        return path
    }

    /// The different elements that make up the path
    public var components: [String] {
        var comps = string.components(separatedBy: Self.separator)
        if path.hasPrefix(Self.separator) {
            comps.insert(Self.separator, at: 0)
        }
        return comps.filter { !$0.isEmpty }
    }
    /// The last element of the path
    public var lastComponent: String {
        return components.last ?? ""
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
        return cStat(path, &s) == 0
    }

    public var description: String {
        return "\(Swift.type(of: self))(\(string))"
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.path == rhs.path
    }
    public static func == <PathType: Path>(lhs: Self, rhs: PathType) -> Bool {
        return lhs.path == rhs.path
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.path < rhs.path
    }
    public static func < <PathType: Path>(lhs: Self, rhs: PathType) -> Bool {
        return lhs.path < rhs.path
    }

    public func change(owner uid: uid_t = ~0, group gid: gid_t = ~0) throws {
        guard chown(string, uid, gid) == 0 else {
            throw ChangeOwnershipError.getError()
        }
    }

    public func change(permissions: FileMode) throws {
        guard chmod(string, permissions.rawValue) == 0 else {
            throw ChangePermissionsError.getError()
        }
    }
}
