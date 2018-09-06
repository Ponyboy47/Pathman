public typealias OpenFile = Open<FilePath>

extension Open where PathType: FilePath {
    public var mayRead: Bool {
        return openPermissions.canRead
    }
    public var mayWrite: Bool {
        return openPermissions.canWrite
    }

    public var openPermissions: OpenFilePermissions { return path.openPermissions }
    public var openFlags: OpenFileFlags { return path.openFlags }
    public var createMode: FileMode? { return path.createMode }
}
