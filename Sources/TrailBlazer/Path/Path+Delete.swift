#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol Deletable {
    func delete() throws
}

extension FilePath: Deletable {
    public func delete() throws {
        guard unlink(string) != -1 else {
            throw DeleteFileError.getError()
        }
    }
}

extension DirectoryPath: Deletable {
    public func delete() throws {
        guard rmdir(string) != -1 else {
            throw DeleteDirectoryError.getError()
        }
    }
}

extension Open: Deletable where PathType: Deletable {
    public func delete() throws {
        try path.delete()
    }
}
