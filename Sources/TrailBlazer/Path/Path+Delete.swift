#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Paths that can be deleted
public protocol Deletable: Creatable {
    /// Deletes a path
    func delete() throws
}

extension FilePath: Deletable {
    /**
    Deletes the file

    - Throws: `DeleteFileError.permissionDenied` when the calling process does not have write access to the directory containing the path or the calling process does not have search permissions to one of the path's components or the calling process does not have permission to delete the path
    - Throws: `DeleteFileError.pathInUse` when the path is in use by the system or another process
    - Throws: `DeleteFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `DeleteFileError.ioError` when an I/O error occurred
    - Throws: `DeleteFileError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `DeleteFileError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `DeleteFileError.noKernelMemory` when there is no available mermory to delete the file
    - Throws: `DeleteFileError.readOnlyFileSystem` when the file system is in read-only mode and so the file cannot be deleted
    - Throws: `CloseFileError.badFileDescriptor` when the file descriptor isn't open or valid (should only occur if you're manually closing it outside of the normal TrailBlazer API)
    - Throws: `CloseFileError.interruptedBySignal` when a signal interrupts the API call
    - Throws: `CloseFileError.ioError` when an I/O error occurred during the API call
    */
    public func delete() throws {
        // No sense in deleting a path that doesn't exist
        guard exists else { return }

        // Be sure to close the file before deleting it or the `.pathInUse` error will be thrown
        try close()

        // Deleting files means unlinking them
        guard unlink(string) != -1 else {
            throw DeleteFileError.getError()
        }
    }
}

extension DirectoryPath: Deletable {
    /**
    Deletes the directory

    - Throws: `DeleteDirectoryError.permissionDenied` when the calling process doesn't have write access to the directory containing the path or the calling process does not have search permissions to one of the path's components
    - Throws: `DeleteDirectoryError.directoryInUse` when the directory is currently in use by the system or some process that prevents its removal. On linux this means the path is being used as a mount point or is the root directory of the calling process
    - Throws: `DeleteDirectoryError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `DeleteDirectoryError.relativePath` when 
    - Throws: `DeleteDirectoryError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `DeleteDirectoryError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `DeleteDirectoryError.noKernelMemory` when there is no available memory to delete the directory
    - Throws: `DeleteDirectoryError.directoryNotEmpty` when the directory cannot be deleted because it is not empty
    - Throws: `DeleteDirectoryError.readOnlyFileSystem` when the file system is in read-only mode and so the directory cannot be deleted
    - Throws: `DeleteDirectoryError.ioError` when an I/O error occurred during the API call
    - Throws: `CloseDirectoryError.badFileDescriptor` when the file descriptor isn't open or valid (should only occur if you're manually closing it outside of the normal TrailBlazer API)
    */
    public func delete() throws {
        // No sense in deleting a path that doesn't exist
        guard exists else { return }

        // Be sure to close the directory before deleting it or the `.pathInUse` error will be thrown
        try close()

        guard rmdir(string) != -1 else {
            throw DeleteDirectoryError.getError()
        }
    }
}

extension Open: Deletable where PathType: Deletable {
    /// Closes and deletes the opened path
    public func delete() throws {
        try _path.delete()
    }
}

extension Open where PathType: DirectoryPath {
    public func recursiveDelete() throws {
        try _path.recursiveDelete()
    }
}
