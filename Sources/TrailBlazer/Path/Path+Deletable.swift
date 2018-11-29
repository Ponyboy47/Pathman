#if os(Linux)
import func Glibc.unlink
#else
import func Darwin.unlink
#endif
private let cUnlink = unlink

extension Path {
    /**
    Deletes the path

    - Throws: `DeleteFileError.permissionDenied` when the calling process does not have write access to the directory
               containing the path or the calling process does not have search permissions to one of the path's
               components or the calling process does not have permission to delete the path
    - Throws: `DeleteFileError.pathInUse` when the path is in use by the system or another process
    - Throws: `DeleteFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `DeleteFileError.ioError` when an I/O error occurred
    - Throws: `DeleteFileError.isDirectory` when the path is a directory (Should only occur if the FilePath object was
               created before the path existed and it was later created as a directory)
    - Throws: `DeleteFileError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `DeleteFileError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `DeleteFileError.noRouteToPath` when the path could not be resolved
    - Throws: `DeleteFileError.pathComponentNotDirectory` when a component of the path was not a directory
    - Throws: `DeleteFileError.noKernelMemory` when there is no available mermory to delete the file
    - Throws: `DeleteFileError.readOnlyFileSystem` when the file system is in read-only mode and so the file cannot be
               deleted
    - Throws: `CloseFileError.badFileDescriptor` when the file descriptor isn't open or valid (should only occur if
               you're manually closing it outside of the normal TrailBlazer API)
    - Throws: `CloseFileError.interruptedBySignal` when a signal interrupts the API call
    - Throws: `CloseFileError.ioError` when an I/O error occurred during the API call
    */
    public mutating func delete() throws {
        // Deleting files means unlinking them
        guard cUnlink(string) != -1 else {
            throw DeleteFileError.getError()
        }
    }
}
