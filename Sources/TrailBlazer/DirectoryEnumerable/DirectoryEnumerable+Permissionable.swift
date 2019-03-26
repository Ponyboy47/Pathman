public extension Permissionable where Self: DirectoryEnumerable {
    /**
    Recursively changes the permissions on all paths

    - Parameter permissions: The new permissions for the paths
    - Parameter options: The options used while enumerating the children of the directory

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
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file
               descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file
               descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory.
               This should only occur if your DirectoryPath object was created before the path existed and then the path
               was created as a non-directory path type
    */
    mutating func changeRecursive(permissions: FileMode,
                                  options: DirectoryEnumerationOptions = .includeHidden) throws {
        let childPaths = try children(options: options)

        for var path in childPaths.notDirectories {
            try path.change(permissions: permissions)
        }

        for var directory in childPaths.directories {
            try directory.changeRecursive(permissions: permissions)
        }

        try change(permissions: permissions)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - owner: The permissions for the owner of the path
        - group: The permissions for members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

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
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file
               descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file
               descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory.
               This should only occur if your DirectoryPath object was created before the path existed and then the path
               was created as a non-directory path type
    */
    mutating func changeRecursive(owner: FilePermissions? = nil,
                                  group: FilePermissions? = nil,
                                  others: FilePermissions? = nil,
                                  bits: FileBits? = nil,
                                  options: DirectoryEnumerationOptions = .includeHidden) throws {
        let current = permissions
        try changeRecursive(permissions: FileMode(owner: owner ?? current.owner,
                                                  group: group ?? current.group,
                                                  others: others ?? current.others,
                                                  bits: bits ?? current.bits),
                            options: options)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - ownerGroup: The permissions for the path owner and also members of the group with access to the path
        - others: The permissions for everyone else accessing the path
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

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
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file
               descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file
               descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory.
               This should only occur if your DirectoryPath object was created before the path existed and then the path
               was created as a non-directory path type
    */
    mutating func changeRecursive(ownerGroup perms: FilePermissions,
                                  others: FilePermissions? = nil,
                                  bits: FileBits? = nil,
                                  options: DirectoryEnumerationOptions = .includeHidden) throws {
        let current = permissions
        try changeRecursive(owner: perms,
                            group: perms,
                            others: current.others,
                            bits: bits ?? current.bits,
                            options: options)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - ownerOthers: The permissions for the owner of the path and everyone else
        - group: The permissions for members of the group with access to the path
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

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
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file
               descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file
               descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory.
               This should only occur if your DirectoryPath object was created before the path existed and then the path
               was created as a non-directory path type
    */
    mutating func changeRecursive(ownerOthers perms: FilePermissions,
                                  group: FilePermissions? = nil,
                                  bits: FileBits? = nil,
                                  options: DirectoryEnumerationOptions = .includeHidden) throws {
        let current = permissions
        try changeRecursive(owner: perms,
                            group: group ?? current.group,
                            others: perms,
                            bits: bits ?? current.bits,
                            options: options)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - groupOthers: The permissions for members of the group with access to the path and anyone else
        - owner: The permissions for the owner of the path
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

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
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file
               descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file
               descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory.
               This should only occur if your DirectoryPath object was created before the path existed and then the path
               was created as a non-directory path type
    */
    mutating func changeRecursive(groupOthers perms: FilePermissions,
                                  owner: FilePermissions? = nil,
                                  bits: FileBits? = nil,
                                  options: DirectoryEnumerationOptions = .includeHidden) throws {
        let current = permissions
        try changeRecursive(owner: owner ?? current.owner,
                            group: perms,
                            others: perms,
                            bits: bits ?? current.bits,
                            options: options)
    }

    /**
    Recursively changes the permissions on all paths

    - Parameters:
        - ownerGroupOthers: The permissions for the owner of the path, members of the group, and everyone else
        - bits: The gid, uid, and sticky bits of the path
        - options: The options used while enumerating the children of the directory

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
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file
               descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file
               descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory.
               This should only occur if your DirectoryPath object was created before the path existed and then the path
               was created as a non-directory path type
    */
    mutating func changeRecursive(ownerGroupOthers perms: FilePermissions,
                                  bits: FileBits? = nil,
                                  options: DirectoryEnumerationOptions = .includeHidden) throws {
        try changeRecursive(owner: perms, group: perms, others: perms, bits: bits ?? permissions.bits, options: options)
    }
}
