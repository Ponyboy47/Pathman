import Foundation

public typealias FileDescriptor = Int32

public protocol Openable: StatDelegate {
    associatedtype PathType: Path

    var path: PathType { get }
    var fileDescriptor: FileDescriptor { get }

    func open() throws
    func close() throws
}

private var _permissions: [UUID: OpenFilePermissions] = [:]
private var _flags: [UUID: OpenFileFlags] = [:]
private var _modes: [UUID: FileMode] = [:]
private var _dirs: [UUID: OpaquePointer] = [:]
private var _buffers: [UUID: UnsafeMutablePointer<CChar>] = [:]
private var _bufferSizes: [UUID: Int] = [:]

public class Open<PathType: Path>: Openable {
    lazy var id: UUID = {
        return UUID()
    }()
    public let path: PathType
    public internal(set) var fileDescriptor: FileDescriptor = -1
    public var offset: Int = 0

    var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    var permissions: OpenFilePermissions? {
        get {
            return _permissions[id]
        }
        set {
            _permissions[id] = newValue
        }
    }
    var flags: OpenFileFlags? {
        get {
            return _flags[id]
        }
        set {
            _flags[id] = newValue
        }
    }
    var mode: FileMode? {
        get {
            return _modes[id]
        }
        set {
            _modes[id] = newValue
        }
    }

    var dir: OpaquePointer? {
        get {
            return _dirs[id]
        }
        set {
            _dirs[id] = newValue
        }
    }

    var buffer: UnsafeMutablePointer<CChar>? {
        get {
            return _buffers[id]
        }
        set {
            _buffers[id] = newValue
        }
    }
    var bufferSize: Int? {
        get {
            return _bufferSizes[id]
        }
        set {
            _bufferSizes[id] = newValue
        }
    }

    public init(_ path: PathType, openNow: Bool = true) throws {
        self.path = path
        guard openNow else { return }
        try self.open()
    }

    public init(_ opened: Open<PathType>) throws {
        path = opened.path
        fileDescriptor = dup(opened.fileDescriptor)
        guard fileDescriptor != -1 else { throw DupError.getError() }
        offset = opened.offset
        flags = opened.flags
        permissions = opened.permissions
        dir = opened.dir
    }

    public func open() throws {
        fatalError("open() has not been implemented for the \(PathType.self) type")
    }

    public func close() throws {
        fatalError("close() has not been implemented for the \(PathType.self) type")
    }

	deinit {
        buffer?.deallocate()
		try? self.close()
	}
}
