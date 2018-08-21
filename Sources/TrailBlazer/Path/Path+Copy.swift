public struct CopyOptions: OptionSet {
    public let rawValue: OSInt

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

    public init(rawValue: OSInt) {
        self.rawValue = rawValue
    }
}

public protocol Copyable: Openable {
    associatedtype CopyablePathType: Path = Self
    func copy(to newPath: CopyablePathType, options: CopyOptions) throws
}

public extension Copyable where Self: Path {
    public func copy(into directory: DirectoryPath, options: CopyOptions = []) throws {
        let newPath = CopyablePathType(directory + lastComponent!) !! "Somehow, a different type of path ended up at \(directory + lastComponent!)"
        try copy(to: newPath, options: options)
    }
}

extension FilePath: Copyable {
    public func copy(to newPath: FilePath, options: CopyOptions = []) throws {
        // Open self with read permissions
        let openPath: OpenFile
        if let open = opened {
            if open.mayRead {
                openPath = open
            } else {
                openPath = try self.open(permissions: .read)
            }
        } else {
            openPath = try open(permissions: .read)
        }
        // Make sure we're at the beginning of the file
        try openPath.rewind()

        // Create the path we're going to copy
        let newOpenPath = try newPath.create(mode: permissions, forceMode: true)

        // If we're not buffering, the buffer size is just the whole file size.
        // If we are buffering, follow the Linux cp(1) implementation, which
        // reads 32 kb at a time.
        let bufferSize: OSInt = options.contains(.noBuffer) ? size : 32.kb

        // If we're not buffering, this should really only run once
        repeat {
            try newOpenPath.write(try openPath.read(bytes: bufferSize))
        } while !openPath.eof // Stop reading from the file once we've reached the EOF
    }
}

extension DirectoryPath: Copyable {
    public func copy(to newPath: DirectoryPath, options: CopyOptions) throws {
        let openPath: OpenDirectory
        if let open = opened {
            openPath = open
            openPath.rewind()
        } else {
            openPath = try open()
        }

        let childrenPaths = openPath.children(includeHidden: options.contains(.includeHidden))

        // The cp(1) utility skips directories unless the recursive options is
        // used. Let's be a little nicer and only skip non-empty directories
        guard childrenPaths.isEmpty || options.contains(.recursive) else { throw CopyError.nonEmptyDirectory }

        try newPath.create(mode: permissions, forceMode: true)

        for file in childrenPaths.files {
            try file.copy(into: newPath, options: options)
        }
        for directory in childrenPaths.directories {
            try directory.copy(into: newPath, options: options)
        }

        guard childrenPaths.other.isEmpty else { throw CopyError.uncopyablePath(childrenPaths.other.first!) }
    }
}
