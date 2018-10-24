import Cdirent

#if os(Linux)
/// The directory stream type used for readding directory entries
public typealias DIRType = OpaquePointer

extension DIRType: Descriptor {
    public var fileDescriptor: FileDescriptor { return dirfd(self) }
}
#else
/// The directory stream type used for readding directory entries
public typealias DIRType = UnsafeMutablePointer<DIR>

extension UnsafeMutablePointer: Descriptor where Pointee == DIR {
    public var fileDescriptor: FileDescriptor { return dirfd(self) }
}
#endif

/// A Path to a directory
public struct DirectoryPath: Path, Openable, DirectoryEnumerable {
    public typealias DescriptorType = DIRType

    public static let pathType: PathType = .directory

    public var _path: String

    public let _info: StatInfo

    /**
    Initialize from another DirectoryPath (copy constructor)

    - Parameter  path: The path to copy
    */
    public init(_ path: DirectoryPath) {
        self = path
    }

    /**
    Initialize from another Path

    - Parameter path: The path to copy
    */
    public init?(_ path: GenericPath) {
        // Cannot initialize a directory from a non-directory type
        if path.exists {
            guard path._info.type == .directory else { return nil }
        }

        _path = path._path
        _info = StatInfo(path)
        try? _info.getInfo()
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
    public func open(options: Empty) throws -> Open<DirectoryPath> {
        guard let dir = opendir(string) else {
            throw OpenDirectoryError.getError()
        }

        return Open(self, descriptor: dir, options: options) !! "Failed to set the opened directory"
    }

    /**
    Closes the directory, if open

    - Throws: Never
    */
    public static func close(opened: Open<DirectoryPath>) throws {
        guard closedir(opened.descriptor) != -1 else {
            throw CloseDirectoryError.getError()
        }
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
        return PathCollection(try open())
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
}
