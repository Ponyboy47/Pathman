#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol Creatable: Openable {
    associatedtype CreatablePathType: Path & Openable
    func create(mode: FileMode) throws -> Open<CreatablePathType>
}

extension FilePath: Creatable {
    public typealias CreatablePathType = FilePath

    @discardableResult
    public func create(mode: FileMode) throws -> Open<FilePath> {
        return try open(permissions: .write, flags: .create, .excl, mode: mode)
    }
}

extension DirectoryPath: Creatable {
    public typealias CreatablePathType = DirectoryPath

    @discardableResult
    public func create(mode: FileMode) throws -> Open<DirectoryPath> {
        guard mkdir(string, mode.rawValue) != -1 else {
            throw CreateDirectoryError.getError()
        }

        return try self.open(mode: mode)
    }
}

extension Open: Creatable where PathType: Creatable {
    public typealias CreatablePathType = PathType.CreatablePathType

    @discardableResult
    public func create(mode: FileMode) throws -> Open<CreatablePathType> {
        return try path.create(mode: mode)
    }
}
