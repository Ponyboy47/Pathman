public struct DirectoryEnumerationOptions: OptionSet, Hashable {
    public let rawValue: UInt8

    public static let includeHidden = DirectoryEnumerationOptions(rawValue: 1 << 0)

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
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

     - Returns: A PathCollection of all the files, directories, and other paths that are contained in self and its subdirectories
     - Note: Opens any directories that are previously unopened and will close them afterwards if it was only opened for this API call

     - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
     - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
     - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
     - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
     - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
     - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
     */
    public func recursiveChildren(depth: Int = -1, options: DirectoryEnumerationOptions = []) throws -> PathCollection {
        var children: PathCollection = PathCollection()
        // Make sure we're not below the specified depth
        guard depth != 0 else { return children }
        let depth = depth - 1

        let immediateChildren = try self.children(options: options)

        if depth != 0 {
            let dirs = immediateChildren.directories
            children += immediateChildren
            for dir in dirs {
                children += try dir.recursiveChildren(depth: depth, options: options)
            }
        } else {
            children += immediateChildren
        }

        return children
    }
}
