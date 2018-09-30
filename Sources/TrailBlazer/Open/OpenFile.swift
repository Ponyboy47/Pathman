#if os(Linux)
import Glibc
#else
import Darwin
#endif

public typealias OpenFile = Open<FilePath>

extension Open where PathType: FilePath {
    /// Whether or not the path was opened with read permissions
    public var mayRead: Bool {
        return path.mayRead
    }

    /// Whether or not the path was opened with write permissions
    public var mayWrite: Bool {
        return path.mayWrite
    }

    public var openPermissions: OpenFilePermissions { return path.openPermissions }
    public var openFlags: OpenFileFlags { return path.openFlags }
    public var createMode: FileMode? { return path.createMode }
}
