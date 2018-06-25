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
