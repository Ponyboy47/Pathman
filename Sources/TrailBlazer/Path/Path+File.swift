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

private var openFiles: [FilePath: OpenFile] = [:]

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

    public func open(options: OptionInt = 0, mode: FileMode? = nil) throws -> OpenFile {
        if let open = openFiles[self] {
            guard options != open.options else { return open }
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

    public func open(permissions: OpenFilePermissions, flags: OpenFileFlags = [], mode: FileMode? = nil) throws -> OpenFile {
        return try open(options: permissions.rawValue | flags.rawValue, mode: mode)
    }

    public func open(permissions: OpenFilePermissions, flags: [OpenFileFlags], mode: FileMode? = nil) throws -> OpenFile {
        let options = permissions.rawValue | flags.reduce(0) { return $0 | $1.rawValue }
        return try open(options: options, mode: mode)
    }

    public func open(permissions: OpenFilePermissions, flags: OpenFileFlags..., mode: FileMode? = nil) throws -> OpenFile {
        return try open(permissions: permissions, flags: flags, mode: mode)
    }

    public func close() throws {
        guard cCloseFile(fileDescriptor) == 0 else {
            throw CloseFileError.getError()
        }
    }
}
