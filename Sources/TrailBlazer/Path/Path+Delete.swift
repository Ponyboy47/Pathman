#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol Deleteable: Path {
    func delete() throws
}

extension FilePath: Deleteable {
    public func delete() throws {
        guard unlink(string) != -1 else {
            throw DeleteFileError.getError()
        }
    }
}

extension DirectoryPath: Deleteable {
    public func delete() throws {
        guard rmdir(string) != -1 else {
            throw DeleteDirectoryError.getError()
        }
    }
}
