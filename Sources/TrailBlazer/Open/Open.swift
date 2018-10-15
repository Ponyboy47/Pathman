import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol Opened: Ownable, Permissionable {
    associatedtype PathType: Openable

    var path: PathType { get }
    var descriptor: PathType.DescriptorType { get }
    var openOptions: PathType.OpenOptionsType { get }

    init(_ path: PathType, descriptor: PathType.DescriptorType, options: PathType.OpenOptionsType)
}

public final class Open<PathType: Openable>: Opened {
    public let path: PathType
    public let descriptor: PathType.DescriptorType
    public var fileDescriptor: FileDescriptor { return descriptor.fileDescriptor }
    public let openOptions: PathType.OpenOptionsType

    public var _info: StatInfo = StatInfo()

    public var url: URL { return path.url }

    /// Whether or not the path may be read
    public var isReadable: Bool {
        return path.mayRead && path.isReadable
    }

    /// Whether or not the path may be written to
    public var isWritable: Bool {
        return path.mayWrite && path.isWritable
    }

    public init(_ path: PathType, descriptor: PathType.DescriptorType, options: PathType.OpenOptionsType) {
        self.path = PathType(path)
        self.descriptor = descriptor
        openOptions = options

        _info._descriptor = descriptor
        _info._path = path._path
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
        try? PathType.close(descriptor: descriptor)
    }
}

extension Open: Equatable {
    public static func == <OtherPathType: Path & Openable>(lhs: Open<PathType>, rhs: Open<OtherPathType>) -> Bool {
        return lhs.path == rhs.path && lhs.fileDescriptor == rhs.fileDescriptor
    }
}

extension Open: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(fileDescriptor)
        hasher.combine(openOptions)
    }
}

extension Open: CustomStringConvertible {
    public var description: String {
        var data: [(key: String, value: CustomStringConvertible)] = []

        data.append((key: "path", value: path))
        data.append((key: "options", value: String(describing: openOptions)))

        return "\(Swift.type(of: self))(\(data.map({ return "\($0.key): \($0.value)" }).joined(separator: ", ")))"
    }
}
