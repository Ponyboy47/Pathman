/// A Path that can be constrained with permissions
public protocol Permissionable: StatDelegate {
    /// The permissions of the path
    var permissions: FileMode { get set }
    func change(permissions: FileMode) throws
}

public extension Permissionable {
    public var permissions: FileMode {
        get { return info.permissions }
        set { try? change(permissions: newValue) }
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - owner: The permissions for the owner of the path
        - group: The permissions for members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path

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
    public func change(owner: FilePermissions, group: FilePermissions, others: FilePermissions, bits: FileBits) throws {
        try change(permissions: FileMode(owner: owner, group: group, others: others, bits: bits))
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - owner: The permissions for the owner of the path
        - group: The permissions for members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path

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
    public func change(owner: FilePermissions? = nil, group: FilePermissions? = nil, others: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: owner ?? current.owner, group: group ?? current.group, others: others ?? current.others, bits: bits ?? current.bits)
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - ownerGroup: The permissions for the path owner and also members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path

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
    public func change(ownerGroup perms: FilePermissions, others: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: perms, group: perms, others: current.others, bits: bits ?? current.bits)
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - ownerOthers: The permissions for the owner of the path and everyone else
        - group: The permissions for members of the group with access to the path
        - bits: The gid, uid, and sticky bits of the path

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
    public func change(ownerOthers perms: FilePermissions, group: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: perms, group: group ?? current.group, others: perms, bits: bits ?? current.bits)
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - groupOthers: The permissions for members of the group with access to the path and anyone else
        - owner: The permissions for the owner of the path
        - bits: The gid, uid, and sticky bits of the path

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
    public func change(groupOthers perms: FilePermissions, owner: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: owner ?? current.owner, group: perms, others: perms, bits: bits ?? current.bits)
    }

    /**
    Changes the permissions of the path

    - Parameters:
        - ownerGroupOthers: The permissions for the owner of the path, members of the group, and everyone else
        - bits: The gid, uid, and sticky bits of the path

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
    public func change(ownerGroupOthers perms: FilePermissions, bits: FileBits? = nil) throws {
        try change(owner: perms, group: perms, others: perms, bits: bits ?? permissions.bits)
    }
}
