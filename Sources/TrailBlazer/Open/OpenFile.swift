import ErrNo

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

public typealias OpenFile = Open<FilePath>
public extension Open where PathType == FilePath {
    /**
    Opens a file
    */
    public convenience init(_ path: FilePath, permissions: OpenFilePermissions, flags: OpenFileFlags, mode: FileMode? = nil) throws {
        try self.init(path, openNow: false)

        self.permissions = permissions
        self.flags = flags
        self.mode = mode
        try self.open()

        self._info = StatInfo(self.fileDescriptor)
    }

    public convenience init(_ path: FilePath, permissions: OpenFilePermissions, flags: OpenFileFlags..., mode: FileMode? = nil) throws {
        var attributes: OpenFileFlags = []
        flags.forEach { attributes.insert($0) }
        try self.init(path, permissions: permissions, flags: attributes, mode: mode)
    }

    public func open() throws {
        let attributes = (permissions?.rawValue ?? 0) | (flags?.rawValue ?? 0)

		if let mode = self.mode {
            fileDescriptor = cOpenFileWithMode(path.string, attributes, mode.rawValue)
        } else {
            if let flags = self.flags {
                guard !flags.contains(.create) else {
                    throw OpenFileError.createWithoutMode
                }
            }
            fileDescriptor = cOpenFile(path.string, attributes)
        }

        guard fileDescriptor != -1 else { throw OpenFileError.getError() }
    }

    public func close() throws {
		guard cCloseFile(fileDescriptor) == 0 else {
            throw CloseFileError.getError()
        }
    }
}

private var openFiles: [FilePath: OpenFile] = [:]
public extension FilePath {
    /// The currently opened file (if it has been opened previously)
    var opened: Open<FilePath>? { return openFiles[self] }

    /**
    Opens the file if it is unopened, returns the opened file if using the same parameters, or closes the opened file and then opens it if the parameters are different

    - Parameters:
        - permissions: The permissions with which to open the file (.read, .write, or .readWrite)
        - flags: The flags to use for opening the file (see open(2) man pages for info)
        - mode: The FileMode if using the .create flag
    - Throws: OpenFileError, CreateFileError, or CloseFileError
    */
    public func open(permissions: OpenFilePermissions, flags: OpenFileFlags..., mode: FileMode? = nil) throws -> Open<FilePath> {
        var attributes: OpenFileFlags = []
        flags.forEach { attributes.insert($0) }

        if let open = openFiles[self] {
            guard open.permissions != permissions || open.flags != attributes || open.mode != mode else { return open }

            try open.close()
        }

        let open = try Open<FilePath>(self, permissions: permissions, flags: attributes, mode: mode)
        openFiles[self] = open
        return open
    }
}
