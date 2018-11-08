#if os(Linux)
import func Glibc.rmdir
#else
import func Darwin.rmdir
#endif

extension DirectoryPath: Deletable {
    /**
    Deletes the directory

    - Throws: `DeleteDirectoryError.permissionDenied` when the calling process doesn't have write access to the
              directory containing the path or the calling process does not have search permissions to one of the path's
              components
    - Throws: `DeleteDirectoryError.directoryInUse` when the directory is currently in use by the system or some process
              that prevents its removal. On linux this means the path is being used as a mount point or is the root
              directory of the calling process
    - Throws: `DeleteDirectoryError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `DeleteDirectoryError.relativePath` when the last path component is '.'
    - Throws: `DeleteDirectoryError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `DeleteDirectoryError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `DeleteDirectoryError.noRouteToPath` when the path could not be resolved
    - Throws: `DeleteDirectoryError.pathComponentNotDirectory` when a component of the path was not a directory
    - Throws: `DeleteDirectoryError.noKernelMemory` when there is no available memory to delete the directory
    - Throws: `DeleteDirectoryError.directoryNotEmpty` when the directory cannot be deleted because it is not empty
    - Throws: `DeleteDirectoryError.readOnlyFileSystem` when the file system is in read-only mode and so the directory
              cannot be deleted
    - Throws: `DeleteDirectoryError.ioError` (macOS only) when an I/O error occurred during the API call
    */
    public mutating func delete() throws {
        guard rmdir(string) != -1 else {
            throw DeleteDirectoryError.getError()
        }
    }
}
