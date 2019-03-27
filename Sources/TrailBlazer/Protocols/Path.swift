import struct Foundation.URL

#if os(Linux)
import Glibc
/// The C stat(2) API call for checking symlinks
private let cStat = Glibc.lstat
#else
import Darwin
/// The C stat(2) API call for checking symlinks
private let cStat = Darwin.lstat
#endif

/// The separator between components of a path
public var pathSeparator: String = "/"
private let processRoot: DirectoryPath = DirectoryPath(pathSeparator)!

// swiftlint:disable line_length
/// The working directory of the current process
private var currentWorkingDirectory = (try? getCurrentWorkingDirectory()) !! "Failed to get the initial current working directory"
// swiftlint:enable line_length

private func getCurrentWorkingDirectory() throws -> DirectoryPath {
    let buffer = try getcwd(nil, 0) ?! CWDError.getError()

    // getcwd(3) states that the pointer returned by the C call needs to be freed
    defer { buffer.deallocate() }

    return DirectoryPath(String(cString: buffer))!
}

/**
 Whether or not a path exists

 - Parameter path: A String representation of the path to test
 - Returns: Whether or not the path exists
 */
public func pathExists(_ path: String) -> Bool {
    // swiftlint:disable identifier_name
    #if os(Linux)
    var _stat = Glibc.stat()
    #else
    var _stat = Darwin.stat()
    #endif
    // swiftlint:enable identifier_name

    return cStat(path, &_stat) == 0
}

public func changeCWD(to dir: DirectoryPath) throws {
    guard chdir(dir.string) == 0 else {
        throw ChDirError.getError()
    }

    currentWorkingDirectory = dir
}

public func changeCWD(to dir: DirectoryPath, closure: () throws -> Void) throws {
    let oldCWD = currentWorkingDirectory
    try changeCWD(to: dir)
    try closure()
    try changeCWD(to: oldCWD)
}

/// A protocol that describes a Path type and the attributes available to it
public protocol Path: Hashable, CustomStringConvertible, UpdatableStatable, Ownable, Permissionable, Movable,
    Deletable, Codable, Sequence {
    // swiftlint:disable identifier_name
    /// The underlying path representation
    var _path: String { get set }
    // swiftlint:enable identifier_name
    /// A String representation of self
    var string: String { get }
    /// Whether or not the path is a link
    var isLink: Bool { get }
    /// The character used to separate components of a path
    static var separator: String { get }
    static var pathType: PathType { get }

    init(_ path: Self)
    init?(_ path: GenericPath)
}

public extension Path {
    /// The character used to separate components of a path
    static var separator: String {
        get { return pathSeparator }
        set { pathSeparator = newValue }
    }

    /// The character used to separate components of a path
    var separator: String {
        get { return Self.separator }
        nonmutating set { Self.separator = newValue }
    }

    /// The current working directory for the process
    static var cwd: DirectoryPath {
        get { return (try? getCurrentWorkingDirectory()) ?? currentWorkingDirectory }
        set {
            try? changeCWD(to: newValue)
        }
    }

    /// The current working directory for the process
    var cwd: DirectoryPath {
        get { return Self.cwd }
        nonmutating set { Self.cwd = newValue }
    }

    /// The String representation of the path
    var string: String {
        return _path
    }

    /// The different elements that make up the path
    var components: [String] {
        var comps = string.components(separatedBy: Self.separator)
        if string.hasPrefix(Self.separator) {
            comps.insert(Self.separator, at: 0)
        }
        return comps.filter { !$0.isEmpty }
    }

    /// The last element of the path
    var lastComponent: String? {
        return components.last
    }

    /// The last element of the path with the extension removed
    var lastComponentWithoutExtension: String? {
        guard let last = lastComponent else { return nil }

        let extensionLength: Int
        if let length = `extension`?.count {
            extensionLength = length + 1
        } else {
            extensionLength = 0
        }
        return String(last.prefix(last.count - extensionLength))
    }

    /// The extension of the path
    var `extension`: String? {
        guard let last = lastComponent else { return nil }

        let comps = last.components(separatedBy: ".")
        guard comps.count > 1 else { return nil }

        return comps.last!
    }

    /// The directory one level above the current Self's location
    var parent: DirectoryPath {
        get {
            // If we'd be removing the last component then return either the
            // processRoot or the currentWorkingDirectory, depending on whether
            // or not the path is absolute
            guard components.count > 1 else {
                return isAbsolute ? processRoot : currentWorkingDirectory
            }

            // Drop the lastComponent and rebuild the path
            return DirectoryPath(components.dropLast())!
        }
        set {
            try? move(into: newValue)
        }
    }

    /// The URL representation of the path
    var url: URL {
        return URL(fileURLWithPath: _path, isDirectory: exists ? isDirectory : self is DirectoryPath)
    }

    /// A printable description of the current path
    var description: String {
        return "\(Swift.type(of: self))(\"\(string)\")"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(_path)
    }

    /**
     Initialize from another SocketPath (copy constructor)

     - Parameter  path: The path to copy
     */
    init(_ path: Self) {
        self = path
    }

    init?(_ str: String) {
        self.init(GenericPath(str))
    }

    /// Initialize from an array of path elements
    init?(_ components: [String]) {
        self.init(GenericPath(components))
    }

    /// Initialize from a variadic array of path elements
    init?(_ components: String...) {
        self.init(components)
    }

    /// Initialize from a slice of an array of path elements
    init?(_ components: ArraySlice<String>) {
        self.init(Array(components))
    }
}
