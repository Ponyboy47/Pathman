#if os(Linux)
import let Glibc.SEEK_SET
import let Glibc.SEEK_END
import let Glibc.SEEK_CUR
#else
import let Darwin.SEEK_SET
import let Darwin.SEEK_END
import let Darwin.SEEK_CUR
import let Darwin.SEEK_DATA
import let Darwin.SEEK_HOLE
#endif

/// Information needed for seeking within a path
public struct Offset {
    /// The type of seeking to be performed
    public struct OffsetType: RawRepresentable, Equatable {
        public let rawValue: OptionInt

        /// Seek from the beginning of a path
        public static let beginning = OffsetType(rawValue: SEEK_SET)
        /// Seek from the end of a path
        public static let end = OffsetType(rawValue: SEEK_END)
        /// Seek from the current offset of a path
        public static let current = OffsetType(rawValue: SEEK_CUR)
        #if os(macOS)
        /// Seek to the next hole in the data of a path
        public static let hole = OffsetType(rawValue: SEEK_HOLE)
        /// Seek to the next data section of a path
        public static let data = OffsetType(rawValue: SEEK_DATA)
        #endif

        public init(rawValue: OptionInt) {
            self.rawValue = rawValue
        }
    }

    /// An Offset pointing to the beginning of a path
    public static let beginning = Offset(.beginning, 0)
    /// An Offset pointing to the end of a path
    public static let end = Offset(.end, 0)
    /// An Offset pointing to the current offset of a path
    public static let current = Offset(.current, 0)

    /// The type of seeking to be performed
    var type: OffsetType
    /// Either the number of bytes to seek or the offset to begin seeking from
    var bytes: OSOffsetInt

    init(_ type: OffsetType, _ bytes: OSOffsetInt) {
        self.init(type: type, bytes: bytes)
    }

    public init(type: OffsetType, bytes: OSOffsetInt) {
        self.type = type
        self.bytes = bytes
    }
}
