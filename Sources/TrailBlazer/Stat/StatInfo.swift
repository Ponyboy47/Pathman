#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// An overlay for the stat C struct
public final class StatInfo: StatDescriptor, StatPath {
    /// The path to use for the underlying stat(2) C API calls
    var _path: String?
    /// The stat options for the stat(2) C API calls
    var options: StatOptions
    /// The descriptor to use for the underlying fstat(2) C API calls
    var _descriptor: Descriptor?
    var fileDescriptor: FileDescriptor? { return _descriptor?.fileDescriptor }
    /// The underlying stat struct that stores the information from the stat(2) C API calls
    var _buffer: stat

    var exists: Bool {
        if _descriptor != nil {
            return true
        } else if let path = _path {
            return pathExists(path)
        }
        return false
    }

    /// Empty initializer
    init() {
        _path = nil
        options = []
        _descriptor = nil
        _buffer = stat()
    }

    /// Makes a stat(2) C API call with the specified options
    func getInfo(options: StatOptions = []) throws {
        if let fd = fileDescriptor {
            try StatInfo.update(fd, &_buffer)
        } else if let path = _path {
            try StatInfo.update(path, options: options, &_buffer)
        }
    }
}

extension StatInfo: CustomStringConvertible {
    public var description: String {
        return "\(Swift.type(of: self))(path: \(String(describing: _path)), fileDescriptor: \(String(describing: fileDescriptor)), options: \(options), buffer: \(_buffer))"
    }
}
