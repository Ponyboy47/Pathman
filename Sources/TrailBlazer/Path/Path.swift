// Used to import the URL type
import Foundation

#if os(Linux)
import Glibc
/// The C stat(2) API call for checking symlinks
let cStat = Glibc.lstat
/// The C rename(2) API call for moving or renaming paths
let cRename = Glibc.rename
#else
import Darwin
/// The C stat(2) API call for checking symlinks
let cStat = Darwin.lstat
/// The C rename(2) API call for moving or renaming paths
let cRename = Darwin.rename
#endif

/// The separator between components of a path
let pathSeparator: String = "/"
/// The root directory of the swift process using this library
fileprivate var processRoot: DirectoryPath = DirectoryPath(pathSeparator) !! "The '\(pathSeparator)' path separator is incorrect for this system."

/// The working directory of the current process
fileprivate var currentWorkingDirectory = DirectoryPath(String(cString: getcwd(nil, 0))) !! "Failed to get current working directory"

/**
Whether or not a path exists

- Parameter path: A String representation of the path to test for. This must either be relative from the currentWorkingDirectory, or absolute from the processRoot
- Returns: Whether or not the path exists
*/
public func pathExists(_ path: String) -> Bool {
    var s: stat
    #if os(Linux)
    s = Glibc.stat()
    #else
    s = Darwin.stat()
    #endif
    return cStat(path, &s) == 0
}

/// A protocol that describes a Path type and the attributes available to it
public protocol Path: Hashable, Comparable, CustomStringConvertible, Ownable, Permissionable, Movable, Codable {
    /// The underlying path representation
    var _path: String { get set }
    /// A String representation of self
    var string: String { get }
    /// The character used to separate components of a path
    static var separator: String { get }

    /// Initialize a Path from a String
    init?(_ str: String)
    /// Initialize a Path from another Path
    init(_ path: Self)
    /// Initialize a Path from a GenericPath
    init?(_ path: GenericPath)
    /// Initialize a Path from an array of path components
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

    /// The String representation of the path
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

    /// The last element of the path with the extension removed
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

    /// The directory one level above the current Self's location
    public var parent: DirectoryPath {
        get {
            // If we'd be removing the last component then return either the
            // processRoot or the currentWorkingDirectory, depending on whether or
            // not the path is absolute
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

    /// The URL representation of the path
    public var url: URL { return URL(fileURLWithPath: _path, isDirectory: isDirectory) }

    /// A printable description of the current path
    public var description: String {
        return "\(Swift.type(of: self))(\(string))"
    }

    /**
    Determine if two paths are equivalent

    - Parameter lhs: The path to compare
    - Parameter rhs: The path to compare the lhs against

    - Returns: Whether or not the paths are the same
    */
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.string == rhs.string
    }
    /**
    Determine if two paths are equivalent

    - Parameter lhs: The path to compare
    - Parameter rhs: The path to compare the lhs against

    - Returns: Whether or not the paths are the same
    */
    public static func == <PathType: Path>(lhs: Self, rhs: PathType) -> Bool {
        return lhs.string == rhs.string
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.string < rhs.string
    }
    public static func < <PathType: Path>(lhs: Self, rhs: PathType) -> Bool {
        return lhs.string < rhs.string
    }

    /**
    Changes the owner and/or group of the path

    - Parameter owner: The uid of the owner of the path
    - Parameter group: The gid of the group with permissions to access the path

    - Throws: `ChangeOwnershipError.permissionDenied` when the calling process does not have the proper permissions to modify path ownership
    - Throws: `ChangeOwnershipError.badAddress` when the path points to a location outside your addressible address space
    - Throws: `ChangeOwnershipError.tooManySymlinks` when too many symlinks were encounter while resolving the path
    - Throws: `ChangeOwnershipError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangeOwnershipError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangeOwnershipError.noKernelMemory` when there is insufficient memory to change the path's ownership
    - Throws: `ChangeOwnershipError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangeOwnershipError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `ChangeOwnershipError.ioError` when an I/O error occurred during the API call
    */
    public func change(owner uid: uid_t = ~0, group gid: gid_t = ~0) throws {
        guard chown(string, uid, gid) == 0 else {
            throw ChangeOwnershipError.getError()
        }
    }

    /**
    Changes the permissions of the path

    - Parameter permissions: The new permissions to use on the path

    - Throws: `ChangePermissionsError.permissionDenied` when the calling process does not have the proper permissions to modify path permissions
    - Throws: `ChangePermissionsError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `ChangePermissionsError.ioError` when an I/O error occurred during the API call
    - Throws: `ChangePermissionsError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `ChangePermissionsError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangePermissionsError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangePermissionsError.noKernelMemory` when there is insufficient memory to change the path's permissions
    - Throws: `ChangePermissionsError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangePermissionsError.readOnlyFileSystem` when the file system is in read-only mode
    */
    public func change(permissions: FileMode) throws {
        guard chmod(string, permissions.rawValue) == 0 else {
            throw ChangePermissionsError.getError()
        }
    }

    /**
    Moves a path to a new location

    - Parameter newPath: The new location for the path

    - Throws: `MoveError.permissionDenied` the calling process does not have write permissions to either the directory containing the current path or the directory where the newPath is located, or search permission is denied for one of the components of either the current path or the newPath, or the current path is a directory and does not allow write permissions
    - Throws: `MoveError.pathInUse` when the current path or the newPath is a directory that is in use by some process or the system
    - Throws: `MoveError.quotaReached` when the user's quota of disk blocks on the file system has been exhausted
    - Throws: `MoveError.badAddress` when either the current path or the newPath points to a location outside your accessible address space
    - Throws: `MoveError.invalidNewPath` when the newPath contains a prefix of the current path, or more generally, an attempt was made to make a directory a subdirectory of itself
    - Throws: `MoveError.newPathIsDirectory_OldPathIsNot` when the new path points to a directory, but the current path does not
    - Throws: `MoveError.tooManySymlinks` when too many symlinks were encountere while resolving the path
    - Throws: `MoveError.symlinkLimitReached` when the current path already has the maximum number of links to it, or it was a directory and the directory containing newPath has the maximum number of links
    - Throws: `MoveError.pathnameTooLong` when either the current path or newPath have more than `PATH_MAX` number of characters
    - Throws: `MoveError.pathDoesNotExist` when either the current path does not exist, a component of the newPath does not exist, or either the current path or newPath is empty
    - Throws: `MoveError.noKernelMemory` when there is insufficient memory to move the path
    - Throws: `MoveError.fileSystemFull` when the file system has no space available
    - Throws: `MoveError.pathComponentNotDirectory` when a component of either the current path or newPath is not a directory
    - Throws: `MoveError.newPathIsNonEmptyDirectory` when newPath is a non-empty directory
    - Throws: `MoveError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `MoveError.pathsOnDifferentFileSystems` when the current path and newPath are on separate file systems
    */
    public mutating func move(to newPath: MovablePathType) throws {
        guard cRename(string, newPath.string) == 0 else {
            throw MoveError.getError()
        }

        _path = newPath.string
    }

    /**
    Decodes a Path from an unkeyed String container

    - Throws: `CodingError.incorrectPathType` when a path exists that does not match the encoded type
    */
    public init(from decoder: Decoder) throws {
          var container = try decoder.unkeyedContainer()
          let pathString = try container.decode(String.self)
          guard let path = Self(pathString) else {
              throw CodingError.incorrectPathType(pathString)
          }

          self.init(path)
      }

      /// Encodes a Path to an unkeyed String container
      public func encode(to encoder: Encoder) throws {
          var container = encoder.unkeyedContainer()
          try container.encode(string)
      }
}
