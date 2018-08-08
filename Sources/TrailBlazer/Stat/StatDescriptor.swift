#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A protocol specification for types that plan on making fstat(2) C API calls with a file descriptor
protocol StatDescriptor: Stat {
    /// The file descriptor to use for the underlying fstat(2) C API calls
    var fileDescriptor: FileDescriptor? { get set }
    init(_ fileDescriptor: FileDescriptor, buffer: UnsafeMutablePointer<stat>)
    init(_ fileDescriptor: FileDescriptor)
    mutating func update() throws
    static func update(_ fileDescriptor: FileDescriptor, _ buffer: UnsafeMutablePointer<stat>) throws
}

extension StatDescriptor {
    /**
    Get information about a file

    - Throws: `StatError.permissionDenied` when search permission is denied for one of the directories in the path prefix of path
    - Throws: `StatError.badFileDescriptor` when the underlying file descript is not open or invalid
    - Throws: `StatError.outOfMemory` when there is insufficient memory to fill the stat buffer
    - Throws: `StatError.fileTooLarge` when the file descriptor refers to a file whose size, inode number, or number of blocks cannot be represented in, respectively, the types off_t, ino_t, or blkcnt_t
    */
    public static func update(_ fileDescriptor: FileDescriptor, _ buffer: UnsafeMutablePointer<stat>) throws {
        guard fstat(fileDescriptor, buffer) == 0 else { throw StatError.getError() }
    }

    /**
    Updates the stat buffer with the latest information about the path

    - Throws: `StatError.permissionDenied` when search permission is denied for one of the directories in the path prefix of path
    - Throws: `StatError.badFileDescriptor` when the underlying file descript is not open or invalid
    - Throws: `StatError.outOfMemory` when there is insufficient memory to fill the stat buffer
    - Throws: `StatError.fileTooLarge` when the file descriptor refers to a file whose size, inode number, or number of blocks cannot be represented in, respectively, the types off_t, ino_t, or blkcnt_t
    */
    public mutating func update() throws {
        let descriptor = try fileDescriptor ?! StatError.badFileDescriptor
        try Self.update(descriptor, _buffer)
    }

    /**
    Initializes a stat descriptor using the specified descriptor and stores results in the specified buffer

    - Parameter fileDescriptor: The opened file descriptor to the path
    - Parameter buffer: The stat buffer to store results into
    */
    public init(_ fileDescriptor: FileDescriptor, buffer: UnsafeMutablePointer<stat>) {
        self.init(buffer: buffer)
        self.fileDescriptor = fileDescriptor
    }

    /**
    Initializes a stat descriptor using the specified descriptor

    - Parameter fileDescriptor: The opened file descriptor to the path
    */
    public init(_ fileDescriptor: FileDescriptor) {
        let buffer = UnsafeMutablePointer<stat>.allocate(capacity: 1)
        buffer.initialize(to: stat())
        self.init(fileDescriptor, buffer: buffer)
    }
}
