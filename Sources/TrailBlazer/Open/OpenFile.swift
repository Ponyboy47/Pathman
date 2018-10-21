public typealias OpenFile = Open<FilePath>

extension Open where PathType == FilePath {
    /// Whether or not the path was opened with read permissions
    public var mayRead: Bool {
        return openPermissions.mayRead
    }

    /// Whether or not the path was opened with write permissions
    public var mayWrite: Bool {
        return openPermissions.mayWrite
    }

    public var openPermissions: OpenFilePermissions { return openOptions.permissions }
    public var openFlags: OpenFileFlags { return openOptions.flags }
    public var createMode: FileMode? { return openOptions.mode }
}
