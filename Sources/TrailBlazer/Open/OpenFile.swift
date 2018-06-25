public typealias OpenFile = Open<FilePath>
public extension Open where PathType == FilePath {
    /**
    Opens a file
    */
    public convenience init(_ path: FilePath, permissions: OpenFilePermissions, flags: OpenFileFlags = [], mode: FileMode? = nil) throws {
        self.init(path)
        try self.path.open(permissions: permissions, flags: flags, mode: mode)
        self._info = StatInfo(fileDescriptor)
    }

    public convenience init(_ path: FilePath, permissions: OpenFilePermissions, flags: OpenFileFlags..., mode: FileMode? = nil) throws {
        self.init(path)
        try self.path.open(permissions: permissions, flags: flags, mode: mode)
        self._info = StatInfo(fileDescriptor)
    }
}

    /**
    Opens the file if it is unopened, returns the opened file if using the same parameters, or closes the opened file and then opens it if the parameters are different

    - Parameters:
        - permissions: The permissions with which to open the file (.read, .write, or .readWrite)
        - flags: The flags to use for opening the file (see open(2) man pages for info)
        - mode: The FileMode if using the .create flag
    - Throws: OpenFileError, CreateFileError, or CloseFileError
    */
