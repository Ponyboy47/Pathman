#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol CreateablePath {
    @discardableResult func create(mode: FileMode) throws -> Openable
}

extension FilePath: CreateablePath {
    @discardableResult
    public func create(mode: FileMode) throws -> Openable {
        return try create(permissions: .write, mode: mode)
    }

    @discardableResult
    public func create(permissions: OpenFilePermissions, mode: FileMode) throws -> Openable {
        if permissions == .write {
            return try FileWriter(self, permissions: permissions, flags: .create, .excl, mode: mode)
        }

        return try FileReaderWriter(self, permissions: permissions, flags: .create, .excl, mode: mode)
    }
}

extension DirectoryPath: CreateablePath {
    @discardableResult
    public func create(mode: FileMode) throws -> Openable {
        let openDir = try OpenDirectory(self)

        guard mkdir(string, mode.rawValue) != -1 else {
            throw CreateDirectoryError.getError()
        }

        return openDir
    }
}
