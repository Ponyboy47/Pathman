public protocol Movable {
    var parent: DirectoryPath { get }
    mutating func move<PathType: Path>(to newPath: PathType) throws
}

public extension Movable {
    public mutating func move(to newPath: String) throws {
        try move(to: GenericPath(newPath))
    }

    public mutating func rename(to: String) throws {
        try move(to: parent + to)
    }
}
