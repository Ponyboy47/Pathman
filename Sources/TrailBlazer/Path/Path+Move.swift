public protocol Movable {
    var _path: String { get set }
    /// The directy one level above the current Self's location
    var parent: DirectoryPath { get set }
    var components: [String] { get }
    var lastComponent: String? { get }
    mutating func move<PathType: Path>(to newPath: PathType) throws
}

public extension Movable {
    public var parent: DirectoryPath {
        get {
            return DirectoryPath(components.dropLast())!
        }
        set {
            try? self.move(into: newValue)
        }
    }

    public mutating func move(to newPath: String) throws {
        try move(to: GenericPath(newPath))
    }

    public mutating func move(into dir: DirectoryPath) throws {
        guard let last = lastComponent else { return }
        let newPath = dir + last
        try move(to: newPath)
    }

    public mutating func rename(to newName: String) throws {
        try move(to: parent + newName)
    }
}
