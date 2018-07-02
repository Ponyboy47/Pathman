#if os(Linux)
import Glibc
let cStat = Glibc.lstat
#else
import Darwin
let cStat = Darwin.lstat
#endif

let pathSeparator: String = "/"
fileprivate var processRoot: DirectoryPath = DirectoryPath(pathSeparator)!
fileprivate var currentWorkingDirectory: DirectoryPath = DirectoryPath(String(cString: getcwd(nil, Int(PATH_MAX))))!

// Used internally to ensure only this framework can modify the path
protocol _Path: Path {
    /// The underlying path representation
    var path: String { get set }
}

/// A protocol that describes a Path type and the attributes available to it
public protocol Path: Hashable, Comparable, CustomStringConvertible, StatDelegate {
    /// The underlying path representation
    var path: String { get }
    /// A String representation of self
    var string: String { get }
    /// The character used to separate components of a path
    static var separator: String { get }
    /// The root directory for the process
    static var root: DirectoryPath { get set }
    /// The root directory for the process
    var root: DirectoryPath { get set }
    /// The current working directory for the process
    static var cwd: DirectoryPath { get set }
    /// The current working directory for the process
    var cwd: DirectoryPath { get set }

    /// The different elements that make up the path
    var components: [String] { get }
    /// The last element of the path
    var lastComponent: String { get }
    /// The directy one level above the current Self's location
    var parent: DirectoryPath { get }
    /// Whether or not the path is a directory
    var isDirectory: Bool { get }
    /// Whether or not the path is a file
    var isFile: Bool { get }
    /// Whether or not the path is a symlink
    var isLink: Bool { get }
    /// Whether or not the path exists (or is accessible)
    var exists: Bool { get }

    init?(_ str: String)
    init?<PathType: Path>(_ path: PathType)
    init?(_ components: [String])
}

public extension Path {
    public static var separator: String { return pathSeparator }

    public static var root: DirectoryPath {
        get { return processRoot }
        set {
            guard chroot(newValue.string) == 0 else { return }
            processRoot = newValue
        }
    }
    public var root: DirectoryPath {
        get { return Self.root }
        set { Self.root = newValue }
    }

    public static var cwd: DirectoryPath {
        get { return currentWorkingDirectory }
        set {
            guard chdir(newValue.string) == 0 else { return }
            currentWorkingDirectory = newValue
        }
    }
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

    public var components: [String] {
        var comps = string.components(separatedBy: Self.separator)
        if path.hasPrefix(Self.separator) {
            comps.insert(Self.separator, at: 0)
        }
        return comps.filter { !$0.isEmpty }
    }

    public var lastComponent: String {
        return components.last ?? ""
    }

    public var parent: DirectoryPath {
        return DirectoryPath(components.dropLast())!
    }

    public var isDirectory: Bool {
        return exists && info.type == .directory
    }

    public var isFile: Bool {
        return exists && info.type == .regular
    }

    public var isLink: Bool {
        return exists && StatInfo(self, options: .getLinkInfo).type == .link
    }

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
}
