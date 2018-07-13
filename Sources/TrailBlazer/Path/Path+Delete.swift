#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol Deletable: Creatable {
    func delete() throws
}

extension FilePath: Deletable {
    public func delete() throws {
        guard exists else { return }
        try close()

        guard unlink(string) != -1 else {
            throw DeleteFileError.getError()
        }
    }
}

extension DirectoryPath: Deletable {
    public func delete() throws {
        guard exists else { return }
        try close()

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

extension Open where PathType: DirectoryPath {
    public func recursiveDelete() throws {
        try path.recursiveDelete()
    }
}
