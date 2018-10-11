#if os(Linux)
import Glibc
#else
import Darwin
#endif

public typealias OpenDirectory = Open<DirectoryPath>

extension Open: DirectoryEnumerable where PathType: DirectoryPath {
    public var dir: DIRType { return path.dir! }

    func rewind() {
        path.rewind()
    }

    /**
    Retrieves the immediate children of the directory

    - Parameter options: The options used while enumerating the children of the directory

    - Returns: A PathCollection containing all the files, directories, and other paths that are contained in self
    */
    public func children(options: DirectoryEnumerationOptions = []) -> PathCollection {
        // Since the directory is already opened, getting the immediate
        // children is always safe
        return PathCollection(self, options: options)
    }
}
