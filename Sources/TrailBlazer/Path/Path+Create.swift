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

    - Throws: `OpenFileError.permissionDenied` when write access is not allowed to the path or if search permissions were denied on one of the components of the path
    - Throws: `OpenFileError.quotaReached` when the file does not exist and the user's quota of disk blocks or inodes on the filesystem has been exhausted
    - Throws: `OpenFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `OpenFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `OpenFileError.tooManySymlinks` when too many symlinks were encountered while resolving the path name
    - Throws: `OpenFileError.noProcessFileDescriptors` when the calling process has no more available file descriptors
    - Throws: `OpenFileError.noSystemFileDescriptors` when the entire system has no more available file descriptors
    - Throws: `OpenFileError.pathnameTooLong` when the path exceeds PATH_MAX number of characters
    - Throws: `OpenFileError.noDevice` when the path points to a special file and no corresponding device exists
    - Throws: `OpenFileError.noRouteToPath` when the path cannot be resolved
    - Throws: `OpenFileError.noKernelMemory` when there is no memory available for creating the path
    - Throws: `OpenFileError.fileSystemFull` when there is no available disk space for creating the path
    - Throws: `OpenFileError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `OpenFileError.readOnlyFileSystem` when the filesystem is in read only mode and cannot create the path
    - Throws: `OpenFileError.pathBusy` when the path is an executable image which is currently being executed
    - Throws: `OpenFileError.lockedDevice` when the device where path exists is locked from writing
    - Throws: `OpenFileError.ioErrorCreatingPath` when an I/O error occurred while creating the inode for the path
    - Throws: `OpenFileError.pathExists` when creating a path that already exists
    */
    @discardableResult
    public func create(mode: FileMode, ignoreUMask: Bool = false) throws -> Open<FilePath> {
        guard !exists else { throw OpenFileError.pathExists }

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

    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path location
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the calling process has no more available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has no more available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when opening an empty path or if the directory does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough memory available to create the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path exists already and it is not a directory
    - Throws: `OpenDirectoryError.pathExists` when creating a path that already exists
    */
    @discardableResult
    public func create(mode: FileMode, ignoreUMask: Bool = false) throws -> Open<DirectoryPath> {
        guard !exists else { throw OpenDirectoryError.pathExists }

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
