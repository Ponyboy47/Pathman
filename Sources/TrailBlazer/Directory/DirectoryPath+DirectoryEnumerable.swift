extension DirectoryPath: DirectoryEnumerable {
    /**
    Retrieves and files or directories contained within the directory

    - Parameter options: The options used while enumerating the children of the directory

    - Returns: A DirectoryChildren of all the files, directories, and other paths that are contained in self
    - Note: Opens the directory if it is unopened and will close it afterwards if the directory was only opened for this
            API call

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
    */
    public func children(options: DirectoryEnumerationOptions = []) throws -> DirectoryChildren {
        return DirectoryChildren(try open())
    }
}
