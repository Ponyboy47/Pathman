#if os(Linux)
import let Glibc._IOFBF
import let Glibc._IOLBF
import let Glibc._IONBF
import let Glibc.BUFSIZ
#else
import let Darwin._IOFBF
import let Darwin._IOLBF
import let Darwin._IONBF
import let Darwin.BUFSIZ
#endif

public struct BufferMode {
    public enum _RawBufferMode: OptionInt {
        public var rawValue: OptionInt {
            switch self {
            case .none: return _IONBF
            case .line: return _IOLBF
            case .full: return _IOFBF
            }
        }

        case none
        case line
        case full
    }

    public let mode: _RawBufferMode
    public var rawValue: OptionInt { return mode.rawValue }
    public let size: Int
    public let buffer: UnsafeMutablePointer<CChar>?

    public static let none = BufferMode(mode: .none)

    public static let line = BufferMode(mode: .line, size: nil)

    public static func full(size: Int? = Int(BUFSIZ)) -> BufferMode {
        return .init(mode: .full, size: size)
    }

    private init(mode: _RawBufferMode, size: Int? = Int(BUFSIZ)) {
        self.mode = mode
        self.size = size ?? 0
        buffer = mode == .none || size == nil ? nil : UnsafeMutablePointer<CChar>.allocate(capacity: size!)
    }
}
