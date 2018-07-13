#if os(Linux)
import Glibc
private let cOpenFile = Glibc.open(_:_:)
private let cOpenFileWithMode = Glibc.open(_:_:_:)
private let cCloseFile = Glibc.close
#else
import Darwin
private let cOpenFile = Darwin.open(_:_:)
private let cOpenFileWithMode = Darwin.open(_:_:_:)
private let cCloseFile = Darwin.close
#endif

private let fileConditions: Conditions = .newer(than: .seconds(5), threshold: 0.25, minCount: 50)

private var _openFiles: DateSortedDescriptors<FilePath, OpenFile> = [:]
private var openFiles: DateSortedDescriptors<FilePath, OpenFile> {
    get {
        if _openFiles.autoclose == nil {
            _openFiles.autoclose = (percentage: 0.1, conditions: fileConditions, priority: .added, min: -1.0, max: -1.0)
        }
        return _openFiles
    }
    set {
        _openFiles = newValue
        autoclose(_openFiles, percentage: 0.1, conditions: fileConditions)
        _openFiles.autoclose = (percentage: 0.1, conditions: fileConditions, priority: .added, min: -1.0, max: -1.0)
    }
}

/// A Path to a file
public class FilePath: _Path, Openable {
    public typealias OpenableType = FilePath

    public internal(set) var path: String
    public internal(set) var fileDescriptor: FileDescriptor = -1
    public internal(set) var options: OptionInt = 0
    public internal(set) var mode: FileMode? = nil

    /// The currently opened file (if it has been opened previously)
    public var opened: OpenFile? { return openFiles[self] }

    // This is to protect the info from being set externally
    private var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /// Initialize from an array of path elements
    public required init?(_ components: [String]) {
        path = components.filter({ !$0.isEmpty && $0 != FilePath.separator}).joined(separator: GenericPath.separator)
        if let first = components.first, first == FilePath.separator {
            path = first + path
        }
        _info = StatInfo(path)

        if exists {
            guard isFile else { return nil }
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
        if str.count > 1 && str.hasSuffix(FilePath.separator) {
            path = String(str.dropLast())
        } else {
            path = str
        }
        _info = StatInfo(path)

        if exists {
            guard isFile else { return nil }
        }
    }

    public required init?<PathType: Path>(_ path: PathType) {
        // Cannot initialize a file from a directory
        guard PathType.self != DirectoryPath.self else { return nil }

        self.path = path.path
        self._info = path.info

        if exists {
            guard isFile else { return nil }
        }
    }

    @available(*, unavailable, message: "Cannot append to a FilePath")
    public static func + <PathType: Path>(lhs: FilePath, rhs: PathType) -> PathType { fatalError("Cannot append to a FilePath") }

    /**
    Opens the file if it is unopened, returns the opened file if using the same parameters, or closes the opened file and then opens it if the parameters are different

    - Parameters:
        - permissions: The permissions with which to open the file (.read, .write, or .readWrite)
        - flags: The flags to use for opening the file (see open(2) man pages for info)
        - mode: The FileMode if using the .create flag
    - Throws: OpenFileError, CreateFileError, or CloseFileError
    - Warning: Beware opening the same file multiple times with different options. To reduce the number of open file descriptors, a single file can only be opened once at a time. If you open the same path with different permissions or flags, then the previously opened instance will be closed before the new one is opened. ie: if youre going to use a path for reading and writing, then open it using the .readWrite permissions rather than first opening it for reading and then later opening it for writing
    */
    @discardableResult
    public func open(options: OptionInt = 0, mode: FileMode? = nil) throws -> OpenFile {
        // Check if the file is already opened
        if let open = openFiles[self] {
            // If we're trying to open the same file with the same options, just return the already opened file
            guard options != open.options else { return open }

            // If the options are different, close the open file so we can
            // re-open it with the new options
            try open.close()
            openFiles.removeValue(forKey: self)
        }

        if let mode = mode {
            fileDescriptor = cOpenFileWithMode(string, options, mode.rawValue)
        } else {
            let flags = OpenFileFlags(rawValue: options)
            guard !flags.contains(.create) else {
                throw OpenFileError.createWithoutMode
            }
            fileDescriptor = cOpenFile(string, options)
        }

        guard fileDescriptor != -1 else { throw OpenFileError.getError() }

        self.options = options
        self.mode = mode

        let open = OpenFile(self)
        openFiles[self] = open
        return open
    }

    @discardableResult
    public func open(permissions: OpenFilePermissions, flags: OpenFileFlags = [], mode: FileMode? = nil) throws -> OpenFile {
        return try open(options: permissions.rawValue | flags.rawValue, mode: mode)
    }

    @discardableResult
    public func open(permissions: OpenFilePermissions, flags: [OpenFileFlags], mode: FileMode? = nil) throws -> OpenFile {
        let options = permissions.rawValue | flags.reduce(0) { return $0 | $1.rawValue }
        return try open(options: options, mode: mode)
    }

    @discardableResult
    public func open(permissions: OpenFilePermissions, flags: OpenFileFlags..., mode: FileMode? = nil) throws -> OpenFile {
        return try open(permissions: permissions, flags: flags, mode: mode)
    }

    public func close() throws {
        guard fileDescriptor != -1 else { return }

        // Remove the open file from the openFiles dict after we close it
        defer {
            openFiles.removeValue(forKey: self)
            fileDescriptor = -1
        }

        guard cCloseFile(fileDescriptor) == 0 else {
            throw CloseFileError.getError()
        }
    }

    deinit {
        try? close()
    }
}
