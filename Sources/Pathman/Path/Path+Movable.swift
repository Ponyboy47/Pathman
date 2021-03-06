#if os(Linux)
import func Glibc.rename
#else
import func Darwin.rename
#endif
/// The C rename(2) API call for moving or renaming paths
private let cRename = rename

public extension Path {
    /**
     Moves a path to a new location

     - Parameter newPath: The new location for the path

     - Throws: `MoveError.permissionDenied` the calling process does not have write permissions to either the directory
                containing the current path or the directory where the newPath is located, or search permission is denied
                for one of the components of either the current path or the newPath, or the current path is a directory
                and does not allow write permissions
     - Throws: `MoveError.pathInUse` when the current path or the newPath is a directory that is in use by some process
                or the system
     - Throws: `MoveError.quotaReached` when the user's quota of disk blocks on the file system has been exhausted
     - Throws: `MoveError.badAddress` when either the current path or the newPath points to a location outside your
                accessible address space
     - Throws: `MoveError.invalidNewPath` when the newPath contains a prefix of the current path, or more generally, an
                attempt was made to make a directory a subdirectory of itself
     - Throws: `MoveError.newPathIsDirectory_OldPathIsNot` when the new path points to a directory, but the current path
                does not
     - Throws: `MoveError.tooManySymlinks` when too many symlinks were encountere while resolving the path
     - Throws: `MoveError.symlinkLimitReached` when the current path already has the maximum number of links to it, or it
                was a directory and the directory containing newPath has the maximum number of links
     - Throws: `MoveError.pathnameTooLong` when either the current path or newPath have more than `PATH_MAX` number of
                characters
     - Throws: `MoveError.pathDoesNotExist` when either the current path does not exist, a component of the newPath does
                not exist, or either the current path or newPath is empty
     - Throws: `MoveError.noKernelMemory` when there is insufficient memory to move the path
     - Throws: `MoveError.fileSystemFull` when the file system has no space available
     - Throws: `MoveError.pathComponentNotDirectory` when a component of either the current path or newPath is not a
                directory
     - Throws: `MoveError.newPathIsNonEmptyDirectory` when newPath is a non-empty directory
     - Throws: `MoveError.readOnlyFileSystem` when the file system is in read-only mode
     - Throws: `MoveError.pathsOnDifferentFileSystems` when the current path and newPath are on separate file systems
     */
    mutating func move(to newPath: Self) throws {
        guard cRename(string, newPath.string) == 0 else {
            throw MoveError.getError()
        }

        _path = newPath.string
    }
}
