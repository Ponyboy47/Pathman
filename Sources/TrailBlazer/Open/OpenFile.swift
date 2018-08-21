public typealias OpenFile = Open<FilePath>

extension Open where PathType: FilePath {
    public var mayRead: Bool {
        return OpenFilePermissions(rawValue: options & OpenFilePermissions.all.rawValue).canRead
    }
    public var mayWrite: Bool {
        return OpenFilePermissions(rawValue: options & OpenFilePermissions.all.rawValue).canWrite
    }
}
