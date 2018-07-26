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

    - Throws:
        - StatError.permissionDenied: (Shouldn't occur) Search permission is denied for one of the directories in the path prefix of pathname.
        - StatError.badFileDescriptor: fileDescriptor is bad.
        - StatError.badAddress: Bad address.
        - StatError.tooManySymlinks: Too many symbolic links encountered while traversing the path.
        - StatError.pathnameTooLong: (Shouldn't occur) pathname is too long.
        - StatError.noRouteToPathname: (Shouldn't occur) A component of pathname does not exist, or pathname is an empty string.
        - StatError.outOfMemory: Out of memory (i.e., kernel memory).
        - StatError.notADirectory: (Shouldn't occur) A component of the path prefix of pathname is not a directory.
        - StatError.fileTooLarge: fileDescriptor refers to a file whose size, inode number, or number of blocks cannot be represented in, respectively, the types off_t, ino_t, or blkcnt_t.
    */
    public static func update(_ fileDescriptor: FileDescriptor, _ buffer: UnsafeMutablePointer<stat>) throws {
        guard fstat(fileDescriptor, buffer) == 0 else { throw StatError.getError() }
    }

    public mutating func update() throws {
        guard let descriptor = fileDescriptor else {
            throw StatError.badFileDescriptor
        }
        try Self.update(descriptor, _buffer)
    }

    public init(_ fileDescriptor: FileDescriptor, buffer: UnsafeMutablePointer<stat>) {
        self.init(buffer: buffer)
        self.fileDescriptor = fileDescriptor
    }

    public init(_ fileDescriptor: FileDescriptor) {
        let buffer = UnsafeMutablePointer<stat>.allocate(capacity: 1)
        buffer.initialize(to: stat())
        self.init(fileDescriptor, buffer: buffer)
    }
}
