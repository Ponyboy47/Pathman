#if os(Linux)
import func Glibc.fchown
import func Glibc.fchmod
#else
import func Darwin.fchown
import func Darwin.fchmod
#endif

import struct Foundation.URL

public protocol Connected: Opened where PathType: Connectable {}

public final class Connection<PathType: Connectable>: Connected {
    public lazy var path: PathType = { return opened.path }()
    public lazy var descriptor: PathType.DescriptorType = { return opened.descriptor }()
    public lazy var fileDescriptor: FileDescriptor = { return descriptor.fileDescriptor }()
    public lazy var openOptions: PathType.OpenOptionsType = { return opened.openOptions }()

    private let opened: Open<PathType>

    // swiftlint:disable identifier_name
    public let _info: StatInfo
    // swiftlint:enable identifier_name

    public var url: URL { return path.url }

    /// Whether or not the path may be read
    public var isReadable: Bool {
        return path.mayRead && path.isReadable
    }

    /// Whether or not the path may be written to
    public var isWritable: Bool {
        return path.mayWrite && path.isWritable
    }

    init(_ opened: Open<PathType>) {
        self.opened = opened
        _info = StatInfo(opened.descriptor)
    }

    /**
    Changes the owner and/or group of the path

    - Parameter owner: The uid of the owner of the path
    - Parameter group: The gid of the group with permissions to access the path

    - Throws: `ChangeOwnershipError.permissionDenied` when the calling process does not have the proper permissions to
               modify path ownership
    - Throws: `ChangeOwnershipError.badAddress` when the path points to a location outside your addressible address
               space
    - Throws: `ChangeOwnershipError.tooManySymlinks` when too many symlinks were encounter while resolving the path
    - Throws: `ChangeOwnershipError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `ChangeOwnershipError.pathDoesNotExist` when the path does not exist
    - Throws: `ChangeOwnershipError.noKernelMemory` when there is insufficient memory to change the path's ownership
    - Throws: `ChangeOwnershipError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `ChangeOwnershipError.readOnlyFileSystem` when the file system is in read-only mode
    - Throws: `ChangeOwnershipError.badFileDescriptor` when the file descriptor is not valid or open
    - Throws: `ChangeOwnershipError.ioError` when an I/O error occurred during the API call
    */
    public func change(owner uid: UID = ~0, group gid: GID = ~0) throws {
        guard fchown(fileDescriptor, uid, gid) == 0 else {
            throw ChangeOwnershipError.getError()
        }
    }

    /**
    Changes the permissions of the path

    - Parameter permissions: The new permissions to use on the path

    - Throws: `ChangePermissionsError.permissionDenied` when the calling process does not have the proper permissions to
               modify path permissions
    - Throws: `ChangePermissionsError.badAddress` when the path points to a location outside your accessible address
               space
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
        try? PathType.shutdown(connected: self)
        // No need to close the opened object. It should become deinitialized
        // (and therefore closed) now since this connection object holds the
        // only reference to it
    }
}

extension Connection: Equatable {
    public static func == <OtherPathType: Path & Connectable>(lhs: Connection<PathType>,
                                                              rhs: Connection<OtherPathType>) -> Bool {
        return lhs.path == rhs.path && lhs.fileDescriptor == rhs.fileDescriptor
    }
}

extension Connection: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(fileDescriptor)
        hasher.combine(openOptions)
    }
}

extension Connection: CustomStringConvertible {
    public var description: String {
        var data: [(key: String, value: CustomStringConvertible)] = []

        data.append((key: "path", value: path))
        data.append((key: "options", value: String(describing: openOptions)))

        return "\(Swift.type(of: self))(\(data.map({ return "\($0.key): \($0.value)" }).joined(separator: ", ")))"
    }
}
