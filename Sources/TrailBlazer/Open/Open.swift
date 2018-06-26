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

public class Open<PathType: Path & Openable>: Openable {
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
    }

    @available(*, renamed: "PathType.open", message: "You should use the path's open function rather than calling this directly.")
    public func open(options: OptionInt, mode: FileMode? = nil) throws -> Open<OpenableType> {
        return try path.open(options: options, mode: mode)
    }

    public func close() throws {
        try path.close()
    }

	deinit {
        buffer?.deallocate()
		try? close()
	}
}
