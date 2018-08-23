import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Protocol declaration for types that can be opened
public protocol Openable: StatDelegate {
    associatedtype OpenableType: Path & Openable = Self
    associatedtype OpenOptionsType = Void

    /// The underlying file descriptor of the opened path
    var fileDescriptor: FileDescriptor { get }

    /**
    Whether or not the path was opened with read permissions

    NOTE: Just because the path was opened with read permissions does not
    necessarily mean the calling process has access to read the path
    */
    var mayRead: Bool { get }
    /**
    Whether or not the path was opened with write permissions

    NOTE: Just because the path was opened with write permissions does not
    necessarily mean the calling process has access to write the path
    */
    var mayWrite: Bool { get }

    var openOptions: OpenOptionsType? { get }

    /// Opens the path, sets the `fileDescriptor`, and returns the newly opened path
    func open() throws -> Open<OpenableType>
    /// Closes the opened `fileDescriptor`
    func close() throws
}

extension Openable {
    public var mayRead: Bool { return true }
    public var mayWrite: Bool { return true }
    public var openOptions: OpenOptionsType? { return nil }
}

/// Contains the buffer used for reading from a path
private var _buffers: [Int: UnsafeMutablePointer<CChar>] = [:]
/// Tracks the sizes of the read buffers
private var _bufferSizes: [Int: OSInt] = [:]

open class Open<PathType: Path & Openable>: Openable, Ownable, Permissionable, StatDelegate {
    public typealias OpenableType = PathType.OpenableType
    public typealias OpenOptionsType = PathType.OpenOptionsType

    /// The path of which this object is the open representation
    public let path: PathType
    public var fileDescriptor: FileDescriptor { return path.fileDescriptor }
    public var openOptions: OpenOptionsType? { return path.openOptions }

    var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    public var url: URL { return path.url }

    /// The buffer used to store data read from a path
    var buffer: UnsafeMutablePointer<CChar>? {
        get {
            return _buffers[path.hashValue]
        }
        set {
            _buffers[path.hashValue] = newValue
        }
    }
    /// The size of the buffer used to store read data
    var bufferSize: OSInt? {
        get {
            return _bufferSizes[path.hashValue]
        }
        set {
            _bufferSizes[path.hashValue] = newValue
        }
    }

    init(_ path: PathType) {
        self.path = path
        _info.fileDescriptor = self.fileDescriptor
        _info._path = path._path
    }

    @available(*, renamed: "PathType.open", message: "You should use the path's open function rather than calling this directly.")
    public func open() throws -> Open<OpenableType> { return try path.open() }

    public func close() throws {
        try path.close()
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
    - Throws: `ChangeOwnershipError.badFileDescriptor` when the file descriptor is not valid or open
    - Throws: `ChangeOwnershipError.ioError` when an I/O error occurred during the API call
    */
    public func change(owner uid: uid_t = ~0, group gid: gid_t = ~0) throws {
        guard fchown(fileDescriptor, uid, gid) == 0 else {
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
    - Throws: `ChangePermissionsError.badFileDescriptor` when the file descriptor is invalid or not open
    */
    public func change(permissions: FileMode) throws {
        guard fchmod(fileDescriptor, permissions.rawValue) == 0 else {
            throw ChangePermissionsError.getError()
        }
    }

	deinit {
        buffer?.deallocate()
		try? close()
	}
}

extension Open: Equatable where PathType: Equatable {
    public static func == <OtherPathType: Path & Openable>(lhs: Open<PathType>, rhs: Open<OtherPathType>) -> Bool {
        return lhs.path == rhs.path && lhs.fileDescriptor == rhs.fileDescriptor
    }
}

extension Open: CustomStringConvertible {
    public var description: String {
        var data: [(key: String, value: String)] = []

        data.append((key: "path", value: "\(path)"))
        data.append((key: "options", value: String(describing: openOptions)))
        if let seekable = self as? Seekable {
            data.append((key: "offset", "\(seekable.offset)"))
        }

        return "\(Swift.type(of: self))(\(data.map({ return "\($0.key): \($0.value)" }).joined(separator: ", ")))"
    }
}
