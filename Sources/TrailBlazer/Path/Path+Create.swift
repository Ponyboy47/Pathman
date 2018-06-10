#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol CreateablePath {
    associatedtype OpenableType: Openable
    func create(mode: FileMode) throws -> OpenableType
}

extension FilePath: CreateablePath {
    public typealias OpenableType = OpenFile

    @discardableResult
    public func create(mode: FileMode) throws -> OpenFile {
        return try OpenFile(self, permissions: .write, flags: .create, .excl, mode: mode)
    }
}

extension DirectoryPath: CreateablePath {
    public typealias OpenableType = OpenDirectory

    @discardableResult
    public func create(mode: FileMode) throws -> OpenDirectory {
        let openDir = try OpenDirectory(self)

        guard mkdir(string, mode.rawValue) != -1 else {
            throw CreateDirectoryError.getError()
        }

        return openDir
    }
}

public extension Path {
    public static func create<PathType: CreateablePath>(path: PathType, mode: FileMode) throws {
        try path.create(mode: mode)
    }
}
