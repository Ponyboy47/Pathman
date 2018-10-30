#if os(Linux)
import func Glibc.chmod
import func Glibc.geteuid
import func Glibc.getegid
#else
import func Darwin.chmod
import func Darwin.geteuid
import func Darwin.getegid
#endif

/// A Path that can be constrained with permissions
public protocol Permissionable {
    /// The permissions of the path
    var permissions: FileMode { get set }
    mutating func change(permissions: FileMode) throws
}

public extension Permissionable {
    /**
    Changes the permissions of the path

    - Parameters:
        - owner: The permissions for the owner of the path
        - group: The permissions for members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path

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
    */
    public mutating func change(owner: FilePermissions,
                                group: FilePermissions,
                                others: FilePermissions,
                                bits: FileBits) throws {
        try change(permissions: FileMode(owner: owner, group: group, others: others, bits: bits))
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - owner: The permissions for the owner of the path
        - group: The permissions for members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path

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
    */
    public mutating func change(owner: FilePermissions? = nil,
                                group: FilePermissions? = nil,
                                others: FilePermissions? = nil,
                                bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: owner ?? current.owner,
                   group: group ?? current.group,
                   others: others ?? current.others,
                   bits: bits ?? current.bits)
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - ownerGroup: The permissions for the path owner and also members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path

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
    */
    public mutating func change(ownerGroup perms: FilePermissions,
                                others: FilePermissions? = nil,
                                bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: perms, group: perms, others: current.others, bits: bits ?? current.bits)
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - ownerOthers: The permissions for the owner of the path and everyone else
        - group: The permissions for members of the group with access to the path
        - bits: The gid, uid, and sticky bits of the path

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
    */
    public mutating func change(ownerOthers perms: FilePermissions,
                                group: FilePermissions? = nil,
                                bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: perms, group: group ?? current.group, others: perms, bits: bits ?? current.bits)
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - groupOthers: The permissions for members of the group with access to the path and anyone else
        - owner: The permissions for the owner of the path
        - bits: The gid, uid, and sticky bits of the path

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
    */
    public mutating func change(groupOthers perms: FilePermissions,
                                owner: FilePermissions? = nil,
                                bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: owner ?? current.owner, group: perms, others: perms, bits: bits ?? current.bits)
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - ownerGroupOthers: The permissions for the owner of the path, members of the group, and everyone else
        - bits: The gid, uid, and sticky bits of the path

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
    */
    public mutating func change(ownerGroupOthers perms: FilePermissions, bits: FileBits? = nil) throws {
        try change(owner: perms, group: perms, others: perms, bits: bits ?? permissions.bits)
    }
}

extension Permissionable where Self: Statable {
    /// Whether or not the path may be read from by the calling process
    public var isReadable: Bool {
        if geteuid() == owner && permissions.owner.isReadable {
            return true
        } else if getegid() == group && permissions.group.isReadable {
            return true
        }

        return permissions.others.isReadable
    }

    /// Whether or not the path may be read from by the calling process
    public var isWritable: Bool {
        if geteuid() == owner && permissions.owner.isWritable {
            return true
        } else if getegid() == group && permissions.group.isWritable {
            return true
        }

        return permissions.others.isWritable
    }

    /// Whether or not the path may be read from by the calling process
    public var isExecutable: Bool {
        if geteuid() == owner && permissions.owner.isExecutable {
            return true
        } else if getegid() == group && permissions.group.isExecutable {
            return true
        }

        return permissions.others.isExecutable
    }
}

extension Path {
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
    */
    public mutating func change(permissions: FileMode) throws {
        guard chmod(string, permissions.rawValue) == 0 else {
            throw ChangePermissionsError.getError()
        }
    }
}
