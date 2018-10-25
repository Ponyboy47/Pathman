public struct DirectoryEnumerationOptions: OptionSet, Hashable {
    public let rawValue: UInt8

    public static let includeHidden = DirectoryEnumerationOptions(rawValue: 1 << 0)

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public init(copyOptions: CopyOptions) {
        self = copyOptions.contains(.includeHidden) ? .includeHidden : []
    }
}

public protocol DirectoryEnumerable {
    func children(options: DirectoryEnumerationOptions) throws -> PathCollection
}

extension DirectoryEnumerable {
    /**
     Recursively iterates through and retrives all children in all subdirectories

     - Parameter depth: How many subdirectories may be recursively traversed (-1 for infinite depth)
     - Parameter options: The options used while enumerating the children of the directory

     - Returns: A PathCollection of all the files, directories, and other paths that are contained in self and its
               subdirectories
     - Note: Opens any directories that are previously unopened and will close them afterwards if it was only opened for
               this API call

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
    public func recursiveChildren(depth: Int = -1, options: DirectoryEnumerationOptions = []) throws -> PathCollection {
        // Make sure we're not below the specified depth
        guard depth != 0 else { return PathCollection() }

        var children = try self.children(options: options)

        // If we still have remaining depth left (Depth of 1 means only the
        // immediate children), then get and add the children from any
        // directories
        if depth != 1 {
            for dir in children.directories {
                children += try dir.recursiveChildren(depth: depth - 1, options: options)
            }
        }

        return children
    }
}
