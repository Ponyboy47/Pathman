#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A protocol specification for objects making stat(2) C API calls
protocol Stat {
    // swiftlint:disable identifier_name
    /// The underlying stat struct that stores the information from the stat(2) C API calls
    var _buffer: stat { get set }
    // swiftlint:enable identifier_name

    init()
}
