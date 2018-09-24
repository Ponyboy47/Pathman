/** An object containing a collection of files, directories, and other paths
    from some kind of traversal or enumeration (ie: globbing or getting
    directory children)
*/
open class PathCollection: Equatable, CustomStringConvertible {
    /// The file paths
    open internal(set) var files: [FilePath]
    /// The directory paths
    open internal(set) var directories: [DirectoryPath]
    /// Other paths
    open internal(set) var other: [GenericPath]

    /// Whether or not this collection is empty
    open var isEmpty: Bool { return files.isEmpty && directories.isEmpty && other.isEmpty }
    /// The number of paths stored in this collection
    open var count: Int { return files.count + directories.count + other.count }

    open var description: String {
        return "\(type(of: self))(files: \(files), directories: \(directories), other: \(other))"
    }

    /** Initializer
        - Parameter files: The FilePaths to begin with as a part of this collection
        - Parameter directories: The DirectoryPaths to begin with as a part of this collection
        - Parameter other: The remaining Paths to begin with as a part of this collection
    */
    public init(files: [FilePath] = [], directories: [DirectoryPath] = [], other: [GenericPath] = []) {
        self.files = files
        self.directories = directories
        self.other = other
    }

    /// Combine two PathCollections into a single new PathCollection
    public static func + (lhs: PathCollection, rhs: PathCollection) -> PathCollection {
        return PathCollection(files: lhs.files + rhs.files, directories: lhs.directories + rhs.directories, other: lhs.other + rhs.other)
    }

    /// Combines the items from one PathCollection into this PathCollection
    public static func += (lhs: inout PathCollection, rhs: PathCollection) {
        lhs.files += rhs.files
        lhs.directories += rhs.directories
        lhs.other += rhs.other
    }

    /// Whether or not two PathCollections are equivalent
    public static func == (lhs: PathCollection, rhs: PathCollection) -> Bool {
        return lhs.files == rhs.files && lhs.directories == rhs.directories && lhs.other == rhs.other
    }
}
