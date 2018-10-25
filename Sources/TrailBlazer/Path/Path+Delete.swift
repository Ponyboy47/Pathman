#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Paths that can be deleted
public protocol Deletable {
    /// Deletes a path
    mutating func delete() throws
}

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

extension Deletable where Self: DirectoryEnumerable {
    /**
    Recursively deletes every path inside and below self

    - Warning: This cannot be undone and should be used with extreme caution
    - Note: In order to know which paths are being deleted, every directory that is encountered must be opened and, as a
            result, may throw

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
    - Throws: `DeleteDirectoryError.readOnlyFileSystem` when the file system is in read-only mode and so the directory
              cannot be deleted
    - Throws: `DeleteDirectoryError.ioError` (macOS only) when an I/O error occurred during the API call
    - Throws: `GenericDeleteError.cannotDeleteGenericPath` when the path is a type that is not Deletable. If you
              encounter this error, please log an issue on GitHub so I can add support for deleting the path type
    - Throws: `DeleteFileError.permissionDenied` when the calling process does not have write access to the directory
              containing the path or the calling process does not have search permissions to one of the path's
              components or the calling process does not have permission to delete the path
    - Throws: `DeleteFileError.pathInUse` when the path is in use by the system or another process
    - Throws: `DeleteFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `DeleteFileError.ioError` when an I/O error occurred
    - Throws: `DeleteFileError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `DeleteFileError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `DeleteFileError.noKernelMemory` when there is no available mermory to delete the file
    - Throws: `DeleteFileError.readOnlyFileSystem` when the file system is in read-only mode and so the file cannot be
              deleted
    - Throws: `CloseFileError.badFileDescriptor` when the file descriptor isn't open or valid (should only occur if
              you're manually closing it outside of the normal TrailBlazer API)
    - Throws: `CloseFileError.interruptedBySignal` when a signal interrupts the API call
    - Throws: `CloseFileError.ioError` when an I/O error occurred during the API call
    */
    public mutating func recursiveDelete() throws {
        let childPaths = try children(options: .includeHidden)

        // Delete all the generic paths
        for var generic in childPaths.other {
            try generic.delete()
        }

        // Delete all the files
        for var file in childPaths.files {
            try file.delete()
        }

        // Recursively delete any subdirectories
        for var directory in childPaths.directories {
            try directory.recursiveDelete()
        }

        // Now that the directory is empty, delete it
        try delete()
    }
}
