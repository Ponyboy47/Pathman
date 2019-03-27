/// The FilePath Creatable conformance
extension FilePath: Creatable {
    /**
     Creates a FilePath

     - Parameter mode: The FileMode (permissions) to use for the newly created path
     - Parameter forceMode: Whether or not to try and change the process's umask to guarentee that the FileMode is what
                you want (I've noticed that by default on Ubuntu, others' write access is disabled in the umask. Setting
                this to true should allow you to overcome this limitation)

     - Throws: `CreateFileError.permissionDenied` when write access is not allowed to the path or if search permissions
                were denied on one of the components of the path
     - Throws: `CreateFileError.quotaReached` when the user's quota of disk blocks or inodes on the filesystem has been
                exhausted
     - Throws: `CreateFileError.badAddress` when the path points to a location outside your accessible address space
     - Throws: `CreateFileError.interruptedBySignal` when the call was interrupted by a signal handler
     - Throws: `CreateFileError.tooManySymlinks` when too many symlinks were encountered while resolving the path name
     - Throws: `CreateFileError.noProcessFileDescriptors` when the calling process has no more available file descriptors
     - Throws: `CreateFileError.noSystemFileDescriptors` when the entire system has no more available file descriptors
     - Throws: `CreateFileError.pathnameTooLong` when the path exceeds PATH_MAX number of characters
     - Throws: `CreateFileError.noDevice` when the path points to a special file and no corresponding device exists
     - Throws: `CreateFileError.noRouteToPath` when the path cannot be resolved
     - Throws: `CreateFileError.noKernelMemory` when there is no memory available for creating the path
     - Throws: `CreateFileError.fileSystemFull` when there is no available disk space for creating the path
     - Throws: `CreateFileError.pathComponentNotDirectory` when a component of the path is not a directory
     - Throws: `CreateFileError.readOnlyFileSystem` when the filesystem is in read only mode and cannot create the path
     - Throws: `CreateFileError.pathBusy` when the path is an executable image which is currently being executed
     - Throws: `CreateFileError.lockedDevice` when the device where path exists is locked from writing
     - Throws: `CreateFileError.ioErrorCreatingPath` when an I/O error occurred while creating the inode for the path
     - Throws: `CreateFileError.pathExists` when creating a path that already exists
     */
    @discardableResult
    public mutating func create(mode: FileMode? = nil,
                                options: CreateOptions = []) throws -> Open<FilePath> {
        // Create and immediately close any intermediates that don't exist when
        // the .createIntermediates options is used
        if options.contains(.createIntermediates), !parent.exists {
            try parent.create(mode: mode, options: options)
        }

        let opened = try open(permissions: .readWrite, flags: [.create, .exclusive], mode: mode ?? .allPermissions)

        // If the mode is not allowed by the umask, then we'll have to force it
        if let mode = mode {
            try opened.change(permissions: mode)
        }

        return opened
    }
}
