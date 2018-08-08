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
    /// The file descriptor to use for the underlying fstat(2) C API calls
    var fileDescriptor: FileDescriptor?
    /// The underlying stat struct that stores the information from the stat(2) C API calls
    var _buffer: UnsafeMutablePointer<stat>
    /// Whether or not we own the file and can safely free the pointer at deinitialization
    let owned: Bool

    /// Empty initializer
    init() {
        _path = nil
        options = []
        fileDescriptor = nil
        _buffer = UnsafeMutablePointer.allocate(capacity: 1)
        _buffer.initialize(to: stat())
        owned = true
    }

    /** Initializer with a custom stat pointer (Expert mode)
        - Parameter buffer: A pointer to the C stat struct which should be used to store results of the stat(2) C API calls
        - Warning: If you use this initializer, then you must release the buffer pointer yourself
    */
    init(buffer: UnsafeMutablePointer<stat>) {
        _path = nil
        options = []
        fileDescriptor = nil
        _buffer = buffer
        owned = false
    }

    /// Makes a stat(2) C API call with the specified options
    func getInfo(options: StatOptions = []) throws {
        if let fd = self.fileDescriptor {
            try StatInfo.update(fd, _buffer)
        } else if let path = _path {
            try StatInfo.update(path, options: options, _buffer)
        }
    }

    deinit {
        if owned {
            _buffer.deallocate()
        }
    }
}
