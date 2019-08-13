#if os(Linux)
import func Glibc.chown
#else
import func Darwin.chown
#endif

public extension Path {
    /**
     Changes the owner and/or group of the path

     - Parameter owner: The uid of the owner of the path
     - Parameter group: The gid of the group with permissions to access the path

     - Throws: `ChangeOwnershipError.permissionDenied` when the calling process does not have the proper permissions to
                modify path ownership
     - Throws: `ChangeOwnershipError.badAddress` when the path points to a location outside your addressible address
                space
     - Throws: `ChangeOwnershipError.tooManySymlinks` when too many symlinks were encounter while resolving the path
     - Throws: `ChangeOwnershipError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
     - Throws: `ChangeOwnershipError.pathDoesNotExist` when the path does not exist
     - Throws: `ChangeOwnershipError.noKernelMemory` when there is insufficient memory to change the path's ownership
     - Throws: `ChangeOwnershipError.pathComponentNotDirectory` when a component of the path is not a directory
     - Throws: `ChangeOwnershipError.readOnlyFileSystem` when the file system is in read-only mode
     - Throws: `ChangeOwnershipError.ioError` when an I/O error occurred during the API call
     */
    mutating func change(owner uid: UID = ~0, group gid: GID = ~0) throws {
        guard chown(string, uid, gid) == 0 else {
            throw ChangeOwnershipError.getError()
        }
    }
}
