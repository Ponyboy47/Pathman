import struct Cdirent.dirent
import func Cdirent.readdir

/** An object containing a collection of files, directories, and other paths
 from some kind of traversal or enumeration (ie: globbing or getting
 directory children)
 */
public struct DirectoryChildren: Equatable, CustomStringConvertible {
    /// The file paths
    public internal(set) var files: [FilePath]
    /// The directory paths
    public internal(set) var directories: [DirectoryPath]
    /// The socket paths
    public internal(set) var sockets: [SocketPath]
    /// The character paths
    public internal(set) var characters: [CharacterPath]
    /// Other paths
    public internal(set) var other: [GenericPath]

    /// Whether or not this collection is empty
    public var isEmpty: Bool { return files.isEmpty && directories.isEmpty && other.isEmpty }
    /// The number of paths stored in this collection
    public var count: Int { return files.count + directories.count + other.count }

    public var description: String {
        return "\(type(of: self))(files: \(files), directories: \(directories), other: \(other))"
    }

    /** Initializer
     - Parameter files: The FilePaths to begin with as a part of this collection
     - Parameter directories: The DirectoryPaths to begin with as a part of this collection
     - Parameter other: The remaining Paths to begin with as a part of this collection
     */
    public init(files: [FilePath] = [],
                directories: [DirectoryPath] = [],
                sockets: [SocketPath] = [],
                characters: [CharacterPath] = [],
                other: [GenericPath] = []) {
        self.files = files
        self.directories = directories
        self.sockets = sockets
        self.characters = characters
        self.other = other
    }

    public init(_ openDirectory: OpenDirectory, options: DirectoryEnumerationOptions = []) {
        self.init(DirectoryIterator(openDirectory), options: options)
    }

    private init(_ iterator: DirectoryIterator, options: DirectoryEnumerationOptions = []) {
        files = []
        directories = []
        sockets = []
        characters = []
        other = []

        while let path = iterator.next() {
            guard !["..", "."].contains(path.lastComponent) else { continue }

            guard options.contains(.includeHidden) || !(path.lastComponent ?? ".").hasPrefix(".") else { continue }

            self.append(path)
        }
    }

    public mutating func append(_ element: String) {
        let generic = GenericPath(element)
        if FilePath.validatePathType(generic) {
            files.append(FilePath(generic))
        } else if DirectoryPath.validatePathType(generic) {
            directories.append(DirectoryPath(generic))
        } else if SocketPath.validatePathType(generic) {
            sockets.append(SocketPath(generic))
        } else if CharacterPath.validatePathType(generic) {
            characters.append(CharacterPath(generic))
        } else {
            other.append(generic)
        }
    }

    public mutating func append<PathType: Path>(_ element: PathType) {
        // swiftlint:disable force_cast
        if element is GenericPath {
            self.append(element._path)
        } else if element is FilePath {
            files.append(element as! FilePath)
        } else if element is DirectoryPath {
            directories.append(element as! DirectoryPath)
        } else if element is SocketPath {
            sockets.append(element as! SocketPath)
        } else if element is CharacterPath {
            characters.append(element as! CharacterPath)
        } else {
            fatalError("Unimplemented PathType => \(PathType.self)")
        }
        // swiftlint:enable force_cast
    }

    /// Combine two DirectoryChildrens into a single new DirectoryChildren
    public static func + (lhs: DirectoryChildren, rhs: DirectoryChildren) -> DirectoryChildren {
        return DirectoryChildren(files: lhs.files + rhs.files,
                                 directories: lhs.directories + rhs.directories,
                                 sockets: lhs.sockets + rhs.sockets,
                                 characters: lhs.characters + rhs.characters,
                                 other: lhs.other + rhs.other)
    }

    /// Combines the items from one DirectoryChildren into this DirectoryChildren
    public static func += (lhs: inout DirectoryChildren, rhs: DirectoryChildren) {
        lhs.files += rhs.files
        lhs.directories += rhs.directories
        lhs.sockets += rhs.sockets
        lhs.characters += rhs.characters
        lhs.other += rhs.other
    }

    /// Whether or not two DirectoryChildrens are equivalent
    public static func == (lhs: DirectoryChildren, rhs: DirectoryChildren) -> Bool {
        return lhs.files == rhs.files
            && lhs.directories == rhs.directories
            && lhs.sockets == rhs.sockets
            && lhs.characters == rhs.characters
            && lhs.other == rhs.other
    }
}

private struct DirectoryIterator: IteratorProtocol {
    let openDirectory: OpenDirectory
    let path: DirectoryPath

    init(_ openDirectory: OpenDirectory) {
        self.openDirectory = openDirectory
        self.path = openDirectory.path
        self.openDirectory.rewind()
    }

    /**
     Iterates through self

     - Returns: The next path in the directory or nil if all paths have been returned
     */
    func next() -> GenericPath? {
        guard let dir = openDirectory.descriptor else { return nil }
        // Read the next entry in the directory. This C API call should never fail
        guard let entry = readdir(dir) else { return nil }

        // Pulls the directory path from the C dirent struct
        return genPath(entry)
    }

    /**
     Generates a GenericPath from the given dirent pointer

     - Parameter ent: A pointer to the C dirent struct containing the path to generate
     - Returns: A GenericPath to the item pointed to in the dirent struct
     */
    private func genPath(_ ent: UnsafeMutablePointer<dirent>) -> GenericPath {
        // Get the path name (last path component) from the C dirent struct.
        // char[256] in C is converted to a 256 item tuple in Swift. This
        // block converts that to an char * array that can be used to
        // initialize a Swift String using the cString initializer
        let name = withUnsafePointer(to: &ent.pointee.d_name) { (ptr) -> String in
            ptr.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: ent.pointee.d_name)) {
                return String(cString: $0)
            }
        }

        // The full path is the concatenation of self with the path name
        return self.path + name
    }
}
