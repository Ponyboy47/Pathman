/// Paths that can be moved
public protocol Movable {
    /// The directory one level above the current Self's location
    var parent: DirectoryPath { get set }
    /// The last element of the path
    var lastComponent: String? { get }
    mutating func move(to newPath: Self) throws
    static var pathType: PathType { get }

    init(_ str: String)
    init(_ path: GenericPath)
}

public extension Movable {
    mutating func move(to newGenericPath: GenericPath) throws {
        guard Self.validatePathType(newGenericPath) else {
            throw MoveError.moveToDifferentPathType
        }
        try move(to: Self(newGenericPath))
    }

    mutating func move(to newPathString: String) throws {
        try move(to: GenericPath(newPathString))
    }

    mutating func move(into dir: DirectoryPath) throws {
        let last = try lastComponent ?! MoveError.noRouteToPath
        let newPath = dir + last
        try move(to: newPath.string)
    }

    mutating func rename(to newName: String) throws {
        try move(to: (parent + newName).string)
    }

    static func validatePathType(_ path: GenericPath) -> Bool {
        if path.exists {
            guard path._info.type == Self.pathType else { return false }
        }
        return true
    }
}
