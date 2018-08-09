import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Protocol declaration for types that can be opened
public protocol Openable: StatDelegate {
    associatedtype OpenableType: Path & Openable

    /// The underlying file descriptor of the opened path
    var fileDescriptor: FileDescriptor { get }
    /// The raw value of the options used to open the path
    var options: OptionInt { get }
    /// The mode used when creating the file (if the `.create` option was used)
    var mode: FileMode? { get }

    /// Opens the path, sets the `fileDescriptor`, and returns the newly opened path
    func open(options: OptionInt, mode: FileMode?) throws -> Open<OpenableType>
    /// Closes the opened `fileDescriptor`
    func close() throws
}

/// Contains the buffer used for reading from a path
private var _buffers: [Int: UnsafeMutablePointer<CChar>] = [:]
/// Tracks the sizes of the read buffers
private var _bufferSizes: [Int: OSInt] = [:]

open class Open<PathType: Path & Openable>: Openable, Ownable, Permissionable {
    public typealias OpenableType = PathType.OpenableType

    /// The path of which this object is the open representation
    public let _path: PathType
    public var fileDescriptor: FileDescriptor { return _path.fileDescriptor }
    public var options: OptionInt { return _path.options }
    public var mode: FileMode? { return _path.mode }
    /// The offset position of the path
    public var offset: OSInt = 0

    var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    public var url: URL { return _path.url }

    /// The buffer used to store data read from a path
    var buffer: UnsafeMutablePointer<CChar>? {
        get {
            return _buffers[_path.hashValue]
        }
        set {
            _buffers[_path.hashValue] = newValue
        }
    }
    /// The size of the buffer used to store read data
    var bufferSize: OSInt? {
        get {
            return _bufferSizes[_path.hashValue]
        }
        set {
            _bufferSizes[_path.hashValue] = newValue
        }
    }

    init(_ path: PathType) {
        _path = path
        _info.fileDescriptor = self.fileDescriptor
        _info._path = path._path
    }

    @available(*, renamed: "PathType.open", message: "You should use the path's open function rather than calling this directly.")
    public func open(options: OptionInt, mode: FileMode? = nil) throws -> Open<OpenableType> {
        return try _path.open(options: options, mode: mode)
    }

    public func close() throws {
        try _path.close()
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
        return lhs._path == rhs._path && lhs.fileDescriptor == rhs.fileDescriptor && lhs.options == rhs.options && lhs.mode == rhs.mode
    }
}

extension Open: CustomStringConvertible {
    public var description: String {
        return "\(Swift.type(of: self))(path: \(_path), flags: \(OpenFileFlags(rawValue: options & OpenFileFlags.all.rawValue)), permissions: \(OpenFilePermissions(rawValue: options & OpenFilePermissions.all.rawValue)), mode: \(String(describing: mode)), offset: \(offset))"
    }
}
