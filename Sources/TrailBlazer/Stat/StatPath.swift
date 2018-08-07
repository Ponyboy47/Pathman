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
    Get information about a path

    - Parameter path: The path to retrieve information about
    - Parameter options: The options to use for the stat API call
    - Parameter buffer: The buffer where results of the stat API call are stored

    - Throws: `StatError.permissionDenied` when search permission is denied for one of the directories in the path prefix of pathname
    - Throws: `StatError.badAddress` when the path points to a location outside you accessible address space
    - Throws: `StatError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `StatError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `StatError.noRouteToPathname` when a component of the path does not exist or path is an empty string
    - Throws: `StatError.outOfMemory` when there is insufficient memory to store the results of the stat API call
    - Throws: `StatError.notADirectory` when a component of the path is not a directory
    - Throws: `StatError.fileTooLarge` when the path refers to a file whose size, inode number, or number of blocks cannot be represented in, respectively, the types off_t, ino_t, or blkcnt_t
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

    /**
    Get information about a path

    - Parameter options: The options to use for the stat API call

    - Throws: `StatError.permissionDenied` when search permission is denied for one of the directories in the path prefix of pathname
    - Throws: `StatError.badAddress` when the path points to a location outside you accessible address space
    - Throws: `StatError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `StatError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `StatError.noRouteToPathname` when a component of the path does not exist or path is an empty string
    - Throws: `StatError.outOfMemory` when there is insufficient memory to store the results of the stat API call
    - Throws: `StatError.notADirectory` when a component of the path is not a directory
    - Throws: `StatError.fileTooLarge` when the path refers to a file whose size, inode number, or number of blocks cannot be represented in, respectively, the types off_t, ino_t, or blkcnt_t
    */
    public mutating func update(options: StatOptions = []) throws {
        var options = options
        options.insert(self.options)
        guard let path = _path else {
            throw RealPathError.emptyPath
        }
        try Self.update(path, options: options, _buffer)
    }

    /**
    Initializes a stat path using a path

    - Parameter path: The path about which to retrieve information
    - Parameter options: The options to use for the stat API calls
    - Parameter buffer: The buffer where to store the retrieved information
    */
    public init(_ path: String, options: StatOptions = [], buffer: UnsafeMutablePointer<stat>) {
        self.init(buffer: buffer)
        _path = path
        self.options = options
    }

    /**
    Initializes a stat path using a path

    - Parameter path: The path about which to retrieve information
    - Parameter options: The options to use for the stat API calls
    */
    public init(_ path: String, options: StatOptions = []) {
        let buffer = UnsafeMutablePointer<stat>.allocate(capacity: 1)
        buffer.initialize(to: stat())
        self.init(path, options: options, buffer: buffer)
    }

    /**
    Initializes a stat path using a path

    - Parameter path: The path about which to retrieve information
    - Parameter options: The options to use for the stat API calls
    - Parameter buffer: The buffer where to store the retrieved information
    */
    public init<PathType: Path>(_ path: PathType, options: StatOptions = [], buffer: UnsafeMutablePointer<stat>) {
        self.init(path._path, options: options, buffer: buffer)
    }

    /**
    Initializes a stat path using a path

    - Parameter path: The path about which to retrieve information
    - Parameter options: The options to use for the stat API calls
    */
    public init<PathType: Path>(_ path: PathType, options: StatOptions = []) {
        self.init(path._path, options: options)
	}
}
