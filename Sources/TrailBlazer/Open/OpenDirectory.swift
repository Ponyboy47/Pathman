import ErrNo

#if os(Linux)
import Glibc
#else
import Darwin
#endif

public class OpenDirectory: Openable {
    public typealias PathType = DirectoryPath

    public let path: DirectoryPath
    private(set) var dir: OpaquePointer

    // This is to protect the info from being set externally
    var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    public init(_ path: DirectoryPath) throws {
        self.path = path
        self.dir = opendir(path.string)

        guard dir != nil else {
            throw OpenDirectoryError.getError()
        }
    }

    public func close() throws {
        guard closedir(dir) != -1 else {
            throw CloseDirectoryError.getError()
        }
    }

    deinit {
        try? close()
    }
}
