#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// A protocol specification for types that plan on making fstat(2) C API calls with a file descriptor
protocol StatDescriptor: Stat {
    // swiftlint:disable identifier_name
    /// The descriptor to use for the underlying fstat(2) C API calls
    var _descriptor: FileDescriptor? { get set }
    // swiftlint:enable identifier_name
}

extension StatDescriptor {
    /**
     Get information about a file

     - Throws: `StatError.permissionDenied` when search permission is denied for one of the directories in the path
                prefix of path
     - Throws: `StatError.badFileDescriptor` when the underlying file descript is not open or invalid
     - Throws: `StatError.outOfMemory` when there is insufficient memory to fill the stat buffer
     - Throws: `StatError.fileTooLarge` when the file descriptor refers to a file whose size, inode number, or number of
                blocks cannot be represented in, respectively, the types off_t, ino_t, or blkcnt_t
     */
    static func update(_ descriptor: FileDescriptor, _ buffer: inout stat) throws {
        guard fstat(descriptor, &buffer) == 0 else { throw StatError.getError() }
    }

    /**
     Initializes a stat descriptor using the specified descriptor

     - Parameter descriptor: The opened descriptor to the path
     */
    init(_ descriptor: FileDescriptor) {
        self.init()
        _descriptor = descriptor
    }
}
