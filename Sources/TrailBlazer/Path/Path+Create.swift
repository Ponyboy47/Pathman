#if os(Linux)
import Glibc
let cUmask = Glibc.umask
#else
import Darwin
let cUmask = Darwin.umask
#endif

/// A Protocol for Path types that can be created
public protocol Creatable: Openable {
    /// The type of the Path. Must be Openable as well
    associatedtype CreatablePathType: Path & Openable
    /**
    Creates a path

    - Parameter mode: The FileMode (permissions) to use for the newly created path
    - Parameter ignoreUMask: Whether or not to try and change the process's umask to guarentee that the FileMode is what you want (I've noticed that by default on Ubuntu, others' write access is disabled in the umask. Setting this to true should allow you to overcome this limitation)
    */
    @discardableResult
    func create(mode: FileMode, ignoreUMask: Bool) throws -> Open<CreatablePathType>
}

/**
A UMask is basically just a FileMode, only the permissions contained in it are
actually the permissions to be rejected when creating paths
*/
public typealias UMask = FileMode

/// The process's current umask
private var _umask: UMask = originalUMask

/// The process's original umask
public var originalUMask: UMask = {
    // Setting the mask returns the original mask
    let mask = FileMode(rawValue: cUmask(FileMode.allPermissions.rawValue))

    // Reset the mask back to it's original value
    defer { let _ = cUmask(mask.rawValue) }

    return mask
}()

/// The process's last umask
public private(set) var lastUMask: UMask = _umask

/// The process's curent umask
public var umask: UMask {
    get { return _umask }
    set { setUMask(for: newValue) }
}

/**
Sets the process's umask and then returns it

- Parameter mode: The permissions that should be set in the mask
- Returns: The new umask
*/
@discardableResult
public func setUMask(for mode: FileMode) -> UMask {
    lastUMask = FileMode(rawValue: cUmask(mode.rawValue))
    _umask = mode
    _umask.bits = .none
    return _umask
}

/// Changes the umask back to its original umask
public func resetUMask() {
    umask = originalUMask
}

/// The FilePath Creatable conformance
extension FilePath: Creatable {
    public typealias CreatablePathType = FilePath

    /**
    Creates a FilePath

    - Parameter mode: The FileMode (permissions) to use for the newly created path
    - Parameter ignoreUMask: Whether or not to try and change the process's umask to guarentee that the FileMode is what you want (I've noticed that by default on Ubuntu, others' write access is disabled in the umask. Setting this to true should allow you to overcome this limitation)

    - Throws: `CreateFileError.permissionDenied` when write access is not allowed to the path or if search permissions were denied on one of the components of the path
    - Throws: `CreateFileError.quotaReached` when the user's quota of disk blocks or inodes on the filesystem has been exhausted
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
    public func create(mode: FileMode, ignoreUMask: Bool = false) throws -> Open<FilePath> {
        guard !exists else { throw CreateFileError.pathExists }

        if ignoreUMask {
            setUMask(for: mode)
        }
        defer {
            if ignoreUMask {
                resetUMask()
            }
        }

        return try open(permissions: .write, flags: .create, .excl, mode: mode)
    }
}

extension DirectoryPath: Creatable {
    public typealias CreatablePathType = DirectoryPath

    /**
    Creates a DirectoryPath

    - Parameter mode: The FileMode (permissions) to use for the newly created path
    - Parameter ignoreUMask: Whether or not to try and change the process's umask to guarentee that the FileMode is what you want (I've noticed that by default on Ubuntu, others' write access is disabled in the umask. Setting this to true should allow you to overcome this limitation)

    - Throws: `CreateDirectoryError.permissionDenied` when the calling process does not have access to the path location
    - Throws: `CreateDirectoryError.quotaReached` when the user's quota of disk blocks or inodes on the filesystem has been exhausted
    - Throws: `CreateDirectoryError.pathExists` when creating a path that already exists
    - Throws: `CreateDirectoryError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `CreateDirectoryError.tooManySymlinks` when too many symlinks were encountered while resolving the path name
    - Throws: `CreateDirectoryError.pathnameTooLong` when the path exceeds PATH_MAX number of characters
    - Throws: `CreateDirectoryError.noRouteToPath` when the path cannot be resolved
    - Throws: `CreateDirectoryError.noKernelMemory` when there is no memory available for creating the path
    - Throws: `CreateDirectoryError.fileSystemFull` when there is no available disk space for creating the path
    - Throws: `CreateDirectoryError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `CreateDirectoryError.readOnlyFileSystem` when the filesystem is in read only mode and cannot create the path
    - Throws: `CreateDirectoryError.ioError` when an I/O error occurred while creating the inode for the pathIsRootDirectory
    - Throws: `CreateDirectoryError.pathIsRootDirectory` when the path points to the user's root directory
    */
    @discardableResult
    public func create(mode: FileMode, ignoreUMask: Bool = false) throws -> Open<DirectoryPath> {
        guard !exists else { throw CreateDirectoryError.pathExists }

        if ignoreUMask {
            setUMask(for: mode)
        }
        defer {
            if ignoreUMask {
                resetUMask()
            }
        }

        guard mkdir(string, mode.rawValue) != -1 else {
            throw CreateDirectoryError.getError()
        }

        return try self.open(mode: mode)
    }
}

extension Open: Creatable where PathType: Creatable {
    public typealias CreatablePathType = PathType.CreatablePathType

    /**
    Paths cannot be opened until they are created. As such, calling this
    function should be impossible/futile. May be removed in a later release.
    */
    @discardableResult
    public func create(mode: FileMode, ignoreUMask: Bool = false) throws -> Open<CreatablePathType> {
        return try _path.create(mode: mode, ignoreUMask: ignoreUMask)
    }
}
