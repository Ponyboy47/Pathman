/// Paths that can be moved
public protocol Movable {
    /// The directory one level above the current Self's location
    var parent: DirectoryPath { get set }
    /// The last element of the path
    var lastComponent: String? { get }
    mutating func move(to newPath: Self) throws

    init?(_ str: String)
    init?(_ path: GenericPath)
}

public extension Movable {
    public mutating func move(to newGenericPath: GenericPath) throws {
        let newPath = try Self(newGenericPath) ?! MoveError.moveToDifferentPathType
        try move(to: newPath)
    }

    public mutating func move(to newPathString: String) throws {
        try move(to: GenericPath(newPathString))
    }

    public mutating func move(into dir: DirectoryPath) throws {
        let last = try lastComponent ?! MoveError.noRouteToPath
        let newPath = dir + last
        try move(to: newPath.string)
    }

    public mutating func rename(to newName: String) throws {
        try move(to: (parent + newName).string)
    }
}
