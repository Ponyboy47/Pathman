public struct OpenFileMode: Equatable, ExpressibleByStringLiteral, Hashable {
    public var rawValue: String {
        if let ccs = self.ccs {
            return "\(raw),\(ccs)"
        }
        return raw
    }

    private var raw: String
    private var ccs: String?

    /**
     Open text file for reading.
     The stream is positioned at the beginning of the file.
     */
    public static let read: OpenFileMode = "r"
    /**
     Open for reading and writing.
     The stream is positioned at the beginning of the file.
     */
    public static let readPlus: OpenFileMode = "r+"

    /**
     Truncate file to zero length or create text file for writing.
     The stream is positioned at the beginning of the file.
     */
    public static let write: OpenFileMode = "w"
    /**
     Open for reading and writing.
     The file is created if it does not exist, otherwise it is truncated.
     The stream is positioned at the beginning of the file.
     */
    public static let writePlus: OpenFileMode = "w+"

    /**
     Open for appending (writing at end of file).
     The file is created if it does not exist.
     The stream is positioned at the end of the file.
     */
    public static let append: OpenFileMode = "a"
    /**
     Open for reading and appending (writing at end of file).
     The file is created if it does not exist.
     The initial file position for reading is at the beginning of the file, but output is always appended to the end of
     the file.
     */
    public static let appendPlus: OpenFileMode = "a+"

    /**
     Other systems may treat text files and binary files differently, and adding the binary option may be a good idea if
     you do I/O to a binary file and expect that your program may be ported to non-UNIX environments.
     */
    public static let binary: OpenFileMode = "b"
    /**
     Open the file with the O_CLOEXEC flag.
     See open(2) for more information.
     */
    public static let closeOnExecute: OpenFileMode = "e"
    /**
     Open the file exclusively (like the O_EXCL flag of open(2)).
     If the file already exists, fopen() fails.
     */
    public static let exclusive: OpenFileMode = "x"

    public static let none: OpenFileMode = ""

    #if os(Linux)
    /// Do not make the open operation, or subsequent read and write operations, thread cancellation points.
    public static let noCancel: OpenFileMode = "c"
    /**
     Attempt to access the file using mmap(2), rather than I/O system calls (read(2), write(2)).
     Currently, use of mmap(2) is attempted only for a file opened for reading.
     */
    public static let mMap: OpenFileMode = "m"
    /**
     The given string is taken as the name of a coded character set and the stream is marked as wide-oriented.
     Thereafter, internal conversion functions convert I/O to and from the character set string.
     */
    public static func codedCharacterSet(_ string: String) -> OpenFileMode {
        var mode = OpenFileMode()
        mode.ccs = string
        return mode
    }
    #endif

    public var mayRead: Bool { return contains(.read) || isPlus }
    public var mayWrite: Bool { return contains(.write) || isAppending || isPlus }
    public var isAppending: Bool { return contains(.append) }
    public var isBinary: Bool { return contains(.binary) }
    private var isPlus: Bool { return raw.contains("+") }
    public var hasCSS: Bool { return ccs != nil }

    public init(rawValue: String) {
        if rawValue.contains(",ccs=") {
            let parts = rawValue.components(separatedBy: ",ccs=")
            raw = parts.first!
            ccs = parts.last
        } else {
            raw = rawValue
        }
    }

    public init(_ string: String) {
        self.init(rawValue: string)
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public static func == (lhs: OpenFileMode, rhs: OpenFileMode) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public func contains(_ perms: OpenFileMode) -> Bool {
        return raw.contains(perms.raw)
    }
}

extension OpenFileMode: CustomStringConvertible {
    public var description: String {
        return "\(type(of: self))(\(rawValue))"
    }
}

extension OpenFileMode: OptionSet {
    public init() {
        self = .none
    }

    public mutating func formUnion(_ other: OpenFileMode) {
        for char in other.raw {
            guard !raw.contains(char) else { continue }
            raw.append(char)
        }

        if let ccs = other.ccs {
            if let thisCCS = self.ccs, thisCCS != ccs {} else {
                self.ccs = ccs
            }
        }
    }

    public mutating func formIntersection(_ other: OpenFileMode) {
        var newRaw = ""
        for char in other.raw {
            guard raw.contains(char) else { continue }
            newRaw.append(char)
        }
        raw = newRaw

        if let ccs = other.ccs {
            if let thisCCS = self.ccs, thisCCS == ccs {} else {
                self.ccs = nil
            }
        }
    }

    public mutating func formSymmetricDifference(_ other: OpenFileMode) {
        var newRaw = ""
        for char in raw {
            guard !other.raw.contains(char) else { continue }
            newRaw.append(char)
        }
        for char in other.raw {
            guard !raw.contains(char) else { continue }
            newRaw.append(char)
        }
        raw = newRaw

        if let ccs = other.ccs {
            if let thisCCS = self.ccs, thisCCS != ccs {
                self.ccs = nil
            } else {
                self.ccs = nil
            }
        }
    }
}
