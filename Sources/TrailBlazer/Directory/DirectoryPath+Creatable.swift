#if os(Linux)
import func Glibc.mkdir
#else
import func Darwin.mkdir
#endif

extension DirectoryPath: Creatable {
    /**
    Creates a DirectoryPath

    - Parameter mode: The FileMode (permissions) to use for the newly created path
    - Parameter forceMode: Whether or not to try and change the process's umask to guarentee that the FileMode is what
               you want (I've noticed that by default on Ubuntu, others' write access is disabled in the umask. Setting
               this to true should allow you to overcome this limitation)

    - Throws: `CreateDirectoryError.permissionDenied` when the calling process does not have access to the path location
    - Throws: `CreateDirectoryError.quotaReached` when the user's quota of disk blocks or inodes on the filesystem has
               been exhausted
    - Throws: `CreateDirectoryError.pathExists` when creating a path that already exists
    - Throws: `CreateDirectoryError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `CreateDirectoryError.tooManySymlinks` when too many symlinks were encountered while resolving the path
               name
    - Throws: `CreateDirectoryError.pathnameTooLong` when the path exceeds PATH_MAX number of characters
    - Throws: `CreateDirectoryError.noRouteToPath` when the path cannot be resolved
    - Throws: `CreateDirectoryError.noKernelMemory` when there is no memory available for creating the path
    - Throws: `CreateDirectoryError.fileSystemFull` when there is no available disk space for creating the path
    - Throws: `CreateDirectoryError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `CreateDirectoryError.readOnlyFileSystem` when the filesystem is in read only mode and cannot create the
               path
    - Throws: `CreateDirectoryError.ioError` when an I/O error occurred while creating the inode for the
               pathIsRootDirectory
    - Throws: `CreateDirectoryError.pathIsRootDirectory` when the path points to the user's root directory
    */
    @discardableResult
    public mutating func create(mode: FileMode? = nil,
                                options: CreateOptions = []) throws -> Open<DirectoryPath> {
        // Create and immediately close any intermediates that don't exist when
        // the .createIntermediates options is used
        if options.contains(.createIntermediates) && !parent.exists {
            try parent.create(mode: mode, options: options)
        }

        guard mkdir(string, (mode ?? .allPermissions).rawValue) != -1 else {
            throw CreateDirectoryError.getError()
        }

        // If the mode is not allowed by the umask, then we'll have to force it
        if let mode = mode {
            try self.change(permissions: mode)
        }

        return try self.open()
    }
}
