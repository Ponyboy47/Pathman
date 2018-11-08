#if os(Linux)
import func Glibc.rewinddir
#else
import func Darwin.rewinddir
#endif

public typealias OpenDirectory = Open<DirectoryPath>

extension Open: DirectoryEnumerable where PathType == DirectoryPath {
    func rewind() {
        rewinddir(descriptor)
    }

    /**
    Retrieves the immediate children of the directory

    - Parameter options: The options used while enumerating the children of the directory

    - Returns: A DirectoryChildren containing all the files, directories, and other paths that are contained in self
    */
    public func children(options: DirectoryEnumerationOptions = []) -> DirectoryChildren {
        // Since the directory is already opened, getting the immediate
        // children is always safe
        return DirectoryChildren(self, options: options)
    }
}
