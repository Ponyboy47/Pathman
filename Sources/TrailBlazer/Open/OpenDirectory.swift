#if os(Linux)
import Glibc
#else
import Darwin
#endif

public typealias OpenDirectory = Open<DirectoryPath>
public extension Open where PathType == DirectoryPath {
    public func open() throws {
        dir = opendir(path.string)

        guard dir != nil else {
            throw OpenDirectoryError.getError()
        }
    }

    public func close() throws {
        if let dir = self.dir {
            guard closedir(dir) != -1 else {
                throw CloseDirectoryError.getError()
            }
        }
    }
}

