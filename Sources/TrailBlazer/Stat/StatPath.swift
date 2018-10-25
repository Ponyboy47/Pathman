#if os(Linux)
import Glibc
#else
import Darwin
#endif

protocol StatPath: Stat {
    // swiftlint:disable identifier_name
    var _path: String? { get set }
    // swiftlint:enable identifier_name
    var options: StatOptions { get set }
}

extension StatPath {
    /**
    Get information about a path

    - Parameter path: The path to retrieve information about
    - Parameter options: The options to use for the stat API call
    - Parameter buffer: The buffer where results of the stat API call are stored

    - Throws: `StatError.permissionDenied` when search permission is denied for one of the directories in the path
               prefix of pathname
    - Throws: `StatError.badAddress` when the path points to a location outside you accessible address space
    - Throws: `StatError.tooManySymlinks` when too many symlinks were encountered while resolving the path
    - Throws: `StatError.pathnameTooLong` when the path has more than `PATH_MAX` number of characters
    - Throws: `StatError.noRouteToPathname` when a component of the path does not exist or path is an empty string
    - Throws: `StatError.outOfMemory` when there is insufficient memory to store the results of the stat API call
    - Throws: `StatError.notADirectory` when a component of the path is not a directory
    - Throws: `StatError.fileTooLarge` when the path refers to a file whose size, inode number, or number of blocks
               cannot be represented in, respectively, the types off_t, ino_t, or blkcnt_t
    */
    public static func update(_ path: String, options: StatOptions = [], _ buffer: inout stat) throws {
        let statResponse: OptionInt
        if options.contains(.getLinkInfo) {
            statResponse = lstat(path, &buffer)
        } else {
            statResponse = stat(path, &buffer)
        }
        guard statResponse == 0 else { throw StatError.getError() }
    }

    /**
    Initializes a stat path using a path

    - Parameter path: The path about which to retrieve information
    - Parameter options: The options to use for the stat API calls
    */
    public init(_ path: String, options: StatOptions = []) {
        self.init()
        self._path = path
        self.options = options
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
