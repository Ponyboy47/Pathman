#if os(Linux)
import Glibc
#else
import Darwin
#endif

protocol StatPath: Stat {
    var _path: String? { get set }
    var options: StatOptions { get set }
    init<PathType: Path>(_ path: PathType, options: StatOptions, buffer: UnsafeMutablePointer<stat>)
    init<PathType: Path>(_ path: PathType, options: StatOptions)
    init(_ path: String, options: StatOptions, buffer: UnsafeMutablePointer<stat>)
    init(_ path: String, options: StatOptions)
    mutating func update(options: StatOptions) throws
    static func update(_ path: String, options: StatOptions, _ buffer: UnsafeMutablePointer<stat>) throws
}

extension StatPath {
    /**
    Get information about a file

    - Throws:
        - StatError.permissionDenied: Search permission is denied for one of the directories in the path prefix of pathname.
        - StatError.badAddress: Bad address.
        - StatError.tooManySymlinks: Too many symbolic links encountered while traversing the path.
        - StatError.pathnameTooLong: pathname is too long.
        - StatError.noRouteToPathname: A component of pathname does not exist, or pathname is an empty string.
        - StatError.outOfMemory: Out of memory (i.e., kernel memory).
        - StatError.notADirectory: A component of the path prefix of pathname is not a directory.
        - StatError.fileTooLarge: fileDescriptor refers to a file whose size, inode number, or number of blocks cannot be represented in, respectively, the types off_t, ino_t, or blkcnt_t.
    */
    public static func update(_ path: String, options: StatOptions = [], _ buffer: UnsafeMutablePointer<stat>) throws {
        let statResponse: OptionInt
        if options.contains(.getLinkInfo) {
            statResponse = lstat(path, buffer)
        } else {
            statResponse = stat(path, buffer)
        }
        guard statResponse == 0 else { throw StatError.getError() }
    }

    public mutating func update(options: StatOptions = []) throws {
        var options = options
        options.insert(self.options)
        guard let path = _path else {
            throw RealPathError.emptyPath
        }
        try Self.update(path, options: options, _buffer)
    }

    public init(_ path: String, options: StatOptions = [], buffer: UnsafeMutablePointer<stat>) {
        self.init(buffer: buffer)
        _path = path
        self.options = options
    }

    public init(_ path: String, options: StatOptions = []) {
        let buffer = UnsafeMutablePointer<stat>.allocate(capacity: 1)
        buffer.initialize(to: stat())
        self.init(path, options: options, buffer: buffer)
    }

    public init<PathType: Path>(_ path: PathType, options: StatOptions = [], buffer: UnsafeMutablePointer<stat>) {
        self.init(path._path, options: options, buffer: buffer)
    }

    public init<PathType: Path>(_ path: PathType, options: StatOptions = []) {
        self.init(path._path, options: options)
	}
}
