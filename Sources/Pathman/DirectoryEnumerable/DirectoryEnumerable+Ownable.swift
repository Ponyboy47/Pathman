public extension Ownable where Self: DirectoryEnumerable {
    /**
     Recursively changes the owner and group of all files and subdirectories

     - Parameter owner: The uid of the owner of the path
     - Parameter group: The gid of the group with permissions to access the path
     - Parameter options: The options used while enumerating the children of the directory

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
     - Throws: `ChangeOwnershipError.ioError` when an I/O error occurred during the API call
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
    mutating func changeRecursive(owner uid: UID = ~0,
                                  group gid: GID = ~0,
                                  options: DirectoryEnumerationOptions = .includeHidden) throws {
        let childPaths = try children(options: options)

        for var path in childPaths.notDirectories {
            try path.change(owner: uid, group: gid)
        }

        for var directory in childPaths.directories {
            try directory.changeRecursive(owner: uid, group: gid)
        }

        try change(owner: uid, group: gid)
    }

    /**
     Recursively changes the owner and group of all files and subdirectories

     - Parameter owner: The username of the owner of the path
     - Parameter group: The name of the group with permissions to access the path
     - Parameter options: The options used while enumerating the children of the directory

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
     - Throws: `ChangeOwnershipError.ioError` when an I/O error occurred during the API call
     - Throws: `UserInfoError.userDoesNotExist` when there was no user found with the specified username
     - Throws: `UserInfoError.interruptedBySignal` when the API call was interrupted by a signal handler
     - Throws: `UserInfoError.ioError` when an I/O error occurred during the API call
     - Throws: `UserInfoError.noMoreProcessFileDescriptors` when the process has no more available file descriptors
     - Throws: `UserInfoError.noMoreSystemFileDescriptors` when the system has no more available file descriptors
     - Throws: `UserInfoError.outOfMemory` when there is insufficient memory to allocate the underlying C passwd struct
     - Throws: `GroupInfoError.groupDoesNotExist` when there was no group found with the specified name
     - Throws: `GroupInfoError.interruptedBySignal` when the API call was interrupted by a signal handler
     - Throws: `GroupInfoError.ioError` when an I/O error occurred during the API call
     - Throws: `GroupInfoError.noMoreProcessFileDescriptors` when the process has no more available file descriptors
     - Throws: `GroupInfoError.noMoreSystemFileDescriptors` when the system has no more available file descriptors
     - Throws: `GroupInfoError.outOfMemory` when there is insufficient memory to allocate the underlying C group struct
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
    mutating func changeRecursive(owner username: String? = nil,
                                  group groupname: String? = nil,
                                  options: DirectoryEnumerationOptions = .includeHidden) throws {
        let uid: UID
        let gid: GID

        if let username = username {
            uid = try getUserInfo(username: username).pw_uid
        } else {
            uid = ~0
        }

        if let groupname = groupname {
            gid = try getGroupInfo(groupname: groupname).gr_gid
        } else {
            gid = ~0
        }

        try changeRecursive(owner: uid, group: gid, options: options)
    }
}
