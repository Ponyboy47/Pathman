public struct CopyOptions: OptionSet {
    public let rawValue: Int

    /**
    If the path to copy is a directory, use this to recursively copy all of
    its contents as opposed to just its immediate children
    */
    public static let recursive = CopyOptions(rawValue: 1)
    /// If the path to copy is a directory, this option will copy the hidden files as well
    public static let includeHidden = CopyOptions(rawValue: 1 << 1)
    /**
    Instead of using a buffer to copy File contents into the duplicate,
    directly copy the entire file into the other. Beware of using this if the
    file you're copying is large
    */
    public static let noBuffer = CopyOptions(rawValue: 1 << 2)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public protocol Copyable {
    associatedtype CopyablePathType: Openable = Self
    @discardableResult
    func copy(to newPath: inout CopyablePathType, options: CopyOptions) throws -> Open<CopyablePathType>
}

public extension Copyable where Self: Path {
    public func copy(into directory: DirectoryPath, options: CopyOptions = []) throws {
        // swiftlint:disable identifier_name
        let _newPath = directory + lastComponent!
        // swiftlint:enable identifier_name
        var newPath = CopyablePathType(_newPath) !! "Somehow, a different type of path ended up at \(_newPath)"
        try copy(to: &newPath, options: options)
    }
}

extension FilePath: Copyable {
    @discardableResult
    public func copy(to newPath: inout FilePath, options: CopyOptions = []) throws -> Open<CopyablePathType> {
        // Open self with read permissions
        let openPath = try open(permissions: .read)

        // Create the path we're going to copy
        let newOpenPath = try newPath.create(mode: permissions)
        try newOpenPath.change(owner: owner, group: group)

        // If we're not buffering, the buffer size is just the whole file size.
        // If we are buffering, follow the Linux cp(1) implementation, which
        // reads 32 kb at a time.
        let bufferSize: Int = options.contains(.noBuffer) ? Int(size) : 32.kb

        // If we're not buffering, this should really only run once
        repeat {
            try newOpenPath.write(openPath.read(bytes: bufferSize))
        } while (newOpenPath.size != openPath.size) // Stop reading from the file once they're identically sized

        return newOpenPath
    }
}

extension DirectoryPath: Copyable {
    @discardableResult
    public func copy(to newPath: inout DirectoryPath, options: CopyOptions) throws -> Open<CopyablePathType> {
        let childPaths = try children(options: options.contains(.includeHidden) ? .includeHidden : [])

        // The cp(1) utility skips directories unless the recursive options is
        // used. Let's be a little nicer and only skip non-empty directories
        guard childPaths.isEmpty || options.contains(.recursive) else { throw CopyError.nonEmptyDirectory }

        let newOpenPath = try newPath.create(mode: permissions)
        try newOpenPath.change(owner: owner, group: group)

        for file in childPaths.files {
            try file.copy(into: newPath, options: options)
        }
        for directory in childPaths.directories {
            try directory.copy(into: newPath, options: options)
        }

        guard childPaths.other.isEmpty else { throw CopyError.uncopyablePath(childPaths.other.first!) }

        return newOpenPath
    }
}

extension Open: Copyable where PathType: Copyable {
    public typealias CopyablePathType = PathType.CopyablePathType

    @discardableResult
    public func copy(to newPath: inout PathType.CopyablePathType,
                     options: CopyOptions = []) throws -> Open<PathType.CopyablePathType> {
        return try path.copy(to: &newPath, options: options)
    }
}
