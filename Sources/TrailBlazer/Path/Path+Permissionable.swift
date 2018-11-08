#if os(Linux)
import func Glibc.chmod
#else
import func Darwin.chmod
#endif

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
