import Foundation

public protocol Openable: StatDelegate {
    associatedtype OpenableType: Path & Openable

    var fileDescriptor: FileDescriptor { get }
    var options: OptionInt { get }
    var mode: FileMode? { get }

    func open(options: OptionInt, mode: FileMode?) throws -> Open<OpenableType>
    func close() throws
}

private var _buffers: [UUID: UnsafeMutablePointer<CChar>] = [:]
private var _bufferSizes: [UUID: OSInt] = [:]

public class Open<PathType: Path & Openable>: Openable, Ownable {
    public typealias OpenableType = PathType.OpenableType

    lazy var id: UUID = {
        return UUID()
    }()
    public let path: PathType
    public var fileDescriptor: FileDescriptor { return path.fileDescriptor }
    public var options: OptionInt { return path.options }
    public var mode: FileMode? { return path.mode }
    public var offset: OSInt = 0

    var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    var buffer: UnsafeMutablePointer<CChar>? {
        get {
            return _buffers[id]
        }
        set {
            _buffers[id] = newValue
        }
    }
    var bufferSize: OSInt? {
        get {
            return _bufferSizes[id]
        }
        set {
            _bufferSizes[id] = newValue
        }
    }

    init(_ path: PathType) {
        self.path = path
        self._info.fileDescriptor = self.fileDescriptor
        self._info.path = path.path
    }

    @available(*, renamed: "PathType.open", message: "You should use the path's open function rather than calling this directly.")
    public func open(options: OptionInt, mode: FileMode? = nil) throws -> Open<OpenableType> {
        return try path.open(options: options, mode: mode)
    }

    public func close() throws {
        try path.close()
    }

    public func change(owner uid: uid_t = ~0, group gid: gid_t = ~0) throws {
        guard fchown(fileDescriptor, uid, gid) == 0 else {
            throw ChangeOwnershipError.getError()
        }
    }

	deinit {
        buffer?.deallocate()
		try? close()
	}
}

extension Open: Equatable where PathType: Equatable {
    public static func == <OtherPathType: Path & Openable>(lhs: Open<PathType>, rhs: Open<OtherPathType>) -> Bool {
        return lhs.path == rhs.path && lhs.fileDescriptor == rhs.fileDescriptor && lhs.options == rhs.options && lhs.mode == rhs.mode
    }
}
