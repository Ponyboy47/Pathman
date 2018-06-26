import Cdirent

#if os(Linux)
typealias DIRType = OpaquePointer
#else
typealias DIRType = UnsafeMutablePointer<DIR>
#endif

public typealias DirectoryChildren = (files: [FilePath], directories: [DirectoryPath], other: [GenericPath])

private var openDirectories: [DirectoryPath: OpenDirectory] = [:]

/// A Path to a directory
public class DirectoryPath: _Path, Openable, Sequence, IteratorProtocol {
    public typealias OpenableType = DirectoryPath
    public typealias Element = GenericPath

    public internal(set) var path: String
    public var fileDescriptor: FileDescriptor {
        guard let dir = self.dir else { return -1 }
        return dirfd(dir)
    }
    private var dir: DIRType?
    private var finishedTraversal: Bool = false
    public internal(set) var options: OptionInt = 0
    public internal(set) var mode: FileMode? = nil

    // This is to protect the info from being set externally
    private var _info: StatInfo
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /// Initialize from an array of path elements
    public required init?(_ components: [String]) {
        path = components.filter({ !$0.isEmpty && $0 != DirectoryPath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == DirectoryPath.separator {
            path = first + path
        }
        _info = StatInfo(path)

        if exists {
            guard isDirectory else { return nil }
        }
    }

    /// Initialize from a variadic array of path elements
    public convenience init?(_ components: String...) {
        self.init(components)
    }

    /// Initialize from a slice of an array of path elements
    public convenience init?(_ components: ArraySlice<String>) {
        self.init(Array(components))
    }

    public required init?(_ str: String) {
        if str.count > 1 && str.hasSuffix(DirectoryPath.separator) {
            path = String(str.dropLast())
        } else {
            path = str
        }
        _info = StatInfo(path)

        if exists {
            guard isDirectory else { return nil }
        }
    }

    public required init?<PathType: Path>(_ path: PathType) {
        // Cannot initialize a directory from a file
        guard PathType.self != FilePath.self else { return nil }

        self.path = path.path
        self._info = path.info

        if exists {
            guard isDirectory else { return nil }
        }
    }

    public static func + (lhs: DirectoryPath, rhs: String) -> GenericPath {
        return lhs + GenericPath(rhs)
    }

    public static func + <PathType: Path>(lhs: DirectoryPath, rhs: PathType) -> PathType {
        var newPath = lhs.string
        let right = rhs.string

        if !newPath.hasSuffix(DirectoryPath.separator) {
            newPath += DirectoryPath.separator
        }

        if right.hasPrefix(DirectoryPath.separator) {
            newPath += right.dropFirst()
        } else {
            newPath += right
        }

        return PathType(newPath)!
    }

    public static func += (lhs: inout DirectoryPath, rhs: DirectoryPath) {
        lhs = lhs + rhs
    }

    @available(*, unavailable, message: "Appending FilePath to DirectoryPath results in a FilePath, but it is impossible to change the type of the left-hand object from a DirectoryPath to a FilePath")
    public static func += (lhs: inout DirectoryPath, rhs: FilePath) {}

    @discardableResult
    public func open(options: OptionInt = 0, mode: FileMode? = nil) throws -> Open<DirectoryPath> {
        // If the directory is already open, return it
        if let openDir = openDirectories[self] {
            return openDir
        }

        dir = opendir(string)

        guard dir != nil else {
            throw OpenDirectoryError.getError()
        }

        // Add the newly opened directory to the openDirectories dict
        let openDir = Open(self)
        openDirectories[self] = openDir
        return openDir
    }

    public func close() throws {
        guard let dir = self.dir else { return }

        // Be sure to remove the open directory from the dict
        defer {
            openDirectories.removeValue(forKey: self)
            self.dir = nil
        }

        guard closedir(dir) != -1 else {
            throw CloseDirectoryError.getError()
        }
    }

	public func children() throws -> DirectoryChildren {
        return try recursiveChildren(to: 1)
    }

    public func recursiveChildren(depth: Int = -1) throws -> DirectoryChildren {
        return try recursiveChildren(to: depth)
    }

    @discardableResult
    func recursiveChildren(to depth: Int, at cur: Int = 0, children: DirectoryChildren = (files: [], directories: [], other: [])) throws -> DirectoryChildren {
        if dir == nil {
            try open()
        }

        guard depth == -1 || depth < cur else { return children }

        var children = children

        for path in self {
            if let file = FilePath(path) {
                children.files.append(file)
            } else if let dir = DirectoryPath(path) {
                children.directories.append(dir)
                children = try dir.recursiveChildren(to: depth, at: cur + 1, children: children)
            } else {
                children.other.append(path)
            }
        }

        return children
    }

    public func next() -> GenericPath? {
        guard let dir = self.dir else { return nil }
        if finishedTraversal {
            rewinddir(dir)
            finishedTraversal = false
        }
        guard let ent = readdir(dir) else {
          finishedTraversal = true
          return nil
        }
        return genPath(ent)
    }

    private func genPath(_ ent: UnsafeMutablePointer<dirent>) -> GenericPath {
        let name = withUnsafeBytes(of: &ent.pointee.d_name) { (ptr) -> String in
            let charPtr = ptr.baseAddress!.assumingMemoryBound(to: CChar.self)
            return String(cString: charPtr)
        }
        return self + name
    }

    deinit {
        try? close()
    }
}
