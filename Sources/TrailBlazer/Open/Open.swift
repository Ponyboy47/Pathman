import struct Foundation.URL

#if os(Linux)
import func Glibc.fchmod
import func Glibc.fchown
#else
import func Darwin.fchmod
import func Darwin.fchown
#endif

public final class Open<PathType: Openable>: UpdatableStatable, Ownable, Permissionable {
    public let path: PathType
    public private(set) var descriptor: PathType.DescriptorType?
    public lazy var fileDescriptor: FileDescriptor? = { descriptor?.fileDescriptor }()
    public let openOptions: PathType.OpenOptionsType

    // swiftlint:disable identifier_name
    public let _info: StatInfo
    // swiftlint:enable identifier_name

    public var url: URL { return path.url }

    /// Whether or not the path may be read
    public var isReadable: Bool {
        return path.isReadable
    }

    /// Whether or not the path may be written to
    public var isWritable: Bool {
        return path.isWritable
    }

    init(_ path: PathType, descriptor: PathType.DescriptorType, options: PathType.OpenOptionsType) {
        self.path = PathType(path)
        self.descriptor = descriptor
        openOptions = options

        _info = StatInfo(descriptor)
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
        guard let fileDescriptor = self.fileDescriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }
        guard fchown(fileDescriptor, uid, gid) == 0 else {
            throw ChangeOwnershipError.getError()
        }
    }

    /**
     Changes the permissions of the path

     - Parameter permissions: The new permissions to use on the path

     - Throws: `ChangePermissionsError.permissionDenied` when the calling process does not have the proper permissions
                to modify path permissions
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
        guard let fileDescriptor = self.fileDescriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }
        guard fchmod(fileDescriptor, permissions.rawValue) == 0 else {
            throw ChangePermissionsError.getError()
        }
    }

    public func close() throws {
        try PathType.close(opened: self)
        descriptor = nil
    }

    deinit {
        guard descriptor != nil else { return }
        try? close()
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

        return "\(Swift.type(of: self))(\(data.map { "\($0.key): \($0.value)" }.joined(separator: ", ")))"
    }
}
