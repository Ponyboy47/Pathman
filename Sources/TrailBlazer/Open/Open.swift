import ErrNo

#if os(Linux)
import Glibc
let cClose = Glibc.close
#else
import Darwin
let cClose = Darwin.close
#endif

public typealias FileDescriptor = Int32

public class OpenFile: StatDelegate {
    let path: FilePath
    public private(set) var fileDescriptor: FileDescriptor = -1
    public private(set) var permissions: OpenFilePermissions
    public private(set) var flags: OpenFileFlags

    // This is to protect the info from being set externally
    var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /**
    Opens a file
    */
    public init(_ path: FilePath, permissions: OpenFilePermissions, flags: OpenFileFlags, mode: FileMode? = nil) throws {
        self.path = path
        self.permissions = permissions
        self.flags = flags
        let attributes = permissions.rawValue | flags.rawValue

		if let mode = mode {
            fileDescriptor = open(path.string, attributes, mode.rawValue)
        } else {
            guard !flags.contains(.create) else {
                throw OpenError.createWithoutMode
            }
            fileDescriptor = open(path.string, attributes)
        }

        guard fileDescriptor != -1 else { throw OpenError.getError() }

        self._info = StatInfo(fileDescriptor)
    }

    public convenience init(_ path: FilePath, permissions: OpenFilePermissions, flags: OpenFileFlags..., mode: FileMode? = nil) throws {
        var attributes: OpenFileFlags = []
        flags.forEach { attributes.insert($0) }
        try self.init(path, permissions: permissions, flags: attributes, mode: mode)
    }

    public init(_ opened: OpenFile) {
        path = opened.path
        fileDescriptor = opened.fileDescriptor
        flags = opened.flags
        permissions = opened.permissions
    }

    public func close() throws {
		guard cClose(fileDescriptor) == 0 else {
            throw CloseError.getError()
        }
    }

	deinit {
		try? self.close()
	}
}

public extension FilePath {
    public func open(_ permissions: OpenFilePermissions, flags: OpenFileFlags..., mode: FileMode? = nil) throws -> OpenFile {
        var attributes: OpenFileFlags = []
        flags.forEach { attributes.insert($0) }
        return try OpenFile(self, permissions: permissions, flags: attributes, mode: mode)
    }
}
