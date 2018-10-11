import Cdirent

#if os(Linux)
/// The directory stream type used for readding directory entries
public typealias DIRType = OpaquePointer
#else
/// The directory stream type used for readding directory entries
public typealias DIRType = UnsafeMutablePointer<DIR>
#endif

public struct DirectoryEnumerationOptions: OptionSet, Hashable {
    public let rawValue: UInt8

    public static let includeHidden = DirectoryEnumerationOptions(rawValue: 1 << 0)

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

public protocol DirectoryEnumerable {
    func children(options: DirectoryEnumerationOptions) throws -> PathCollection
}

extension DirectoryEnumerable {
    /**
    Recursively iterates through and retrives all children in all subdirectories

    - Parameter depth: How many subdirectories may be recursively traversed (-1 for infinite depth)
    - Parameter options: The options used while enumerating the children of the directory

    - Returns: A PathCollection of all the files, directories, and other paths that are contained in self and its subdirectories
    - Note: Opens any directories that are previously unopened and will close them afterwards if it was only opened for this API call

    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func recursiveChildren(depth: Int = -1, options: DirectoryEnumerationOptions = []) throws -> PathCollection {
        var children: PathCollection = PathCollection()
        // Make sure we're not below the specified depth
        guard depth != 0 else { return children }
        let depth = depth - 1

        let immediateChildren = try self.children(options: options)

        if depth != 0 {
            let dirs = immediateChildren.directories
            children += immediateChildren
            for dir in dirs {
                children += try dir.recursiveChildren(depth: depth, options: options)
            }
        } else {
            children += immediateChildren
        }

        return children
    }
}

/// A Path to a directory
public class DirectoryPath: Path, Openable, Linkable, DirectoryEnumerable {
    public typealias OpenableType = DirectoryPath

    public var _path: String
    public var fileDescriptor: FileDescriptor {
        // Opened directories result in a DIR struct, rather than a straight
        // file descriptor. The dirfd(3) C API call takes a DIR pointer and
        // returns its associated file descriptor

        // Either returns the file descriptor or -1
        return dir == nil ? -1 : dirfd(dir!)
    }

    /// Opening a directory returns a pointer to a DIR struct
    var dir: DIRType? {
        willSet {
            if newValue != nil {
                opened = OpenDirectory(self)
            } else {
                opened = nil
            }
        }
    }

    public var opened: OpenDirectory?

    // This is to protect the info from being set externally
    private var _info: StatInfo
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /// Initialize from an array of path elements
    public required init?(_ components: [String]) {
        _path = components.filter({ !$0.isEmpty && $0 != DirectoryPath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == DirectoryPath.separator {
            _path = first + _path
        }
        _info = StatInfo(_path)

        if exists {
            guard isDirectory else { return nil }
        }
    }

    /// Initialize from a variadic array of path elements
    public convenience init?(_ components: String...) {
        self.init(components)
    }

    /// Initialize from a slice of an array of path elements
    public convenience init?(_ components: ArraySlice<String>) {
        self.init(Array(components))
    }

    public required init?(_ str: String) {
        if str.count > 1 && str.hasSuffix(DirectoryPath.separator) {
            _path = String(str.dropLast())
        } else {
            _path = str
        }
        _info = StatInfo(_path)

        if exists {
            guard isDirectory else { return nil }
        }
    }

    /**
    Initialize from another DirectoryPath (copy constructor)

    - Parameter path: The path to copy
    */
    public required init(_ path: DirectoryPath) {
        _path = path._path
        _info = path.info
    }

    /**
    Initialize from another Path

    - Parameter path: The path to copy
    */
    public required init?(_ path: GenericPath) {
        // Cannot initialize a directory from a non-directory type
        if path.exists {
            guard path.isDirectory else { return nil }
        }

        _path = path._path
        _info = path.info
    }

    /**
    Opens the directory

    - Returns: The opened directory

    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    @discardableResult
    public func open() throws -> Open<DirectoryPath> {
        if let opened = opened { return opened }

        dir = opendir(string)

        guard dir != nil else {
            throw OpenDirectoryError.getError()
        }

        return opened !! "Failed to set the opened directory"
    }

    /**
    Closes the directory, if open

    - Throws: Never
    */
    public func close() throws {
        guard let dir = self.dir else { return }

        // Be sure to remove the open directory from the dict
        defer {
            // When this line was not first, it was not executed for some reason
            self.dir = nil
        }

        // This should never throw since self.dir is private and the only way
        // it would be invalid is if it was previously closed or set to nil
        // (which this library should never do)
        guard closedir(dir) != -1 else {
            throw CloseDirectoryError.getError()
        }
    }

    func rewind() {
        guard let dir = self.dir else { return }
        rewinddir(dir)
    }

    /**
    Retrieves and files or directories contained within the directory

    - Parameter options: The options used while enumerating the children of the directory

    - Returns: A PathCollection of all the files, directories, and other paths that are contained in self
    - Note: Opens the directory if it is unopened and will close it afterwards if the directory was only opened for this API call

    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func children(options: DirectoryEnumerationOptions = []) throws -> PathCollection {
        let unopened = dir == nil

        let children = PathCollection(try open())

        if unopened { try close() }

        return children
    }

    /**
    Appends a String to a DirectoryPath

    - Parameter lhs: The DirectoryPath to append to
    - Parameter rhs: The String to append

    - Returns: A GenericPath which is the combination of the lhs + Path.separator + rhs
    */
    public static func + (lhs: DirectoryPath, rhs: String) -> GenericPath {
        return lhs + GenericPath(rhs)
    }

    /**
    Appends a Path to a DirectoryPath

    - Parameter lhs: The DirectoryPath to append to
    - Parameter rhs: The Path to append

    - Returns: A PathType which is the combination of the lhs + Path.separator + rhs
    */
    public static func + <PathType: Path>(lhs: DirectoryPath, rhs: PathType) -> PathType {
        var newPath = lhs.string
        let right = rhs.string

        if !newPath.hasSuffix(DirectoryPath.separator) {
            newPath += DirectoryPath.separator
        }

        if right.hasPrefix(DirectoryPath.separator) {
            newPath += right.dropFirst()
        } else {
            newPath += right
        }

        return PathType(newPath) !! "Failed to instantiate \(PathType.self) from \(Swift.type(of: newPath)) '\(newPath)'"
    }

    /**
    Append a DirectoryPath to another

    - Parameter lhs: The DirectoryPath to modify
    - Parameter rhs: The DirectoryPath to append
    */
    public static func += (lhs: inout DirectoryPath, rhs: DirectoryPath) {
        lhs = lhs + rhs
    }

    @available(*, unavailable, message: "Appending FilePath to DirectoryPath results in a FilePath, but it is impossible to change the type of the left-hand object from a DirectoryPath to a FilePath")
    public static func += (lhs: inout DirectoryPath, rhs: FilePath) {}

    // Be sure to close any open directories during deconstruction
    deinit {
        try? close()
    }
}
