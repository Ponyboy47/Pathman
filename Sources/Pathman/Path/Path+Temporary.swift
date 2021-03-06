#if os(Linux)
import func Glibc.mkdtemp
import func Glibc.mkstemp
#else
import func Darwin.mkdtemp
import func Darwin.mkstemp
#endif
import class Foundation.FileManager

/// Protocol declaration for Paths that can generate and create a unique temporary path
public protocol TemporaryGeneratable: Creatable {
    static func temporary(base tmpDir: DirectoryPath, prefix: String) throws -> Open<Self>
    // swiftlint:disable identifier_name
    static func _delete(_ opened: Open<Self>) throws
    // swiftlint:enable identifier_name
}

public let temporaryDirectory: DirectoryPath = getTemporaryDirectory()

private func getTemporaryDirectory() -> DirectoryPath {
    if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
        return DirectoryPath(FileManager.default.temporaryDirectory.path)
    } else {
        // Linux has support for getting the temp directory from file manager,
        // but the other OS versions not captured by the #available will not
        #if os(Linux)
        return DirectoryPath(FileManager.default.temporaryDirectory.path)
        #else
        return DirectoryPath("\(GenericPath.separator)tmp")
        #endif
    }
}

extension TemporaryGeneratable {
    // Both mkstemp(3) and mkdtemp(3) require 6 consecutive X's in the template
    fileprivate static func temporaryPathTemplate(_ base: DirectoryPath, _ prefix: String) -> String {
        return (base + "\(prefix)XXXXXX").string
    }

    fileprivate func temporaryPathTemplate(_ base: DirectoryPath, _ prefix: String) -> String {
        return Self.temporaryPathTemplate(base, prefix)
    }

    // swiftlint:disable identifier_name
    public static func _delete(_ opened: Open<Self>) throws {
        var path = opened.path
        try path.delete()
    }

    // swiftlint:enable identifier_name
}

extension FilePath: TemporaryGeneratable {
    /**
     Creates a unique FilePath with the specified prefix

     - Parameter base: The base directory where the temporary path will be placed
     - Parameter prefix: The file name's prefix (before the randomly generated part of the path)
     - Returns: The opened temporary path

     - Throws: `MakeTemporaryError.alreadyExists` when the "unique" path that was generated already exists (hopefully
                shouldn't occur)
     - Throws: `CreateFileError.permissionDenied` when write access is not allowed to the path or if search permissions
                were denied on one of the components of the path
     - Throws: `CreateFileError.quotaReached` when the user's quota of disk blocks or inodes on the filesystem has been
                exhausted
     - Throws: `CreateFileError.interruptedBySignal` when the call was interrupted by a signal handler
     - Throws: `CreateFileError.noProcessFileDescriptors` when the calling process has no more available file descriptors
     - Throws: `CreateFileError.noSystemFileDescriptors` when the entire system has no more available file descriptors
     - Throws: `CreateFileError.noKernelMemory` when there is no memory available for creating the path
     - Throws: `CreateFileError.fileSystemFull` when there is no available disk space for creating the path
     - Throws: `CreateFileError.readOnlyFileSystem` when the filesystem is in read only mode and cannot create the path
     - Throws: `CreateFileError.lockedDevice` when the device where path exists is locked from writing
     - Throws: `CreateFileError.ioErrorCreatingPath` when an I/O error occurred while creating the inode for the path
     */
    public static func temporary(base tmpDir: DirectoryPath = temporaryDirectory,
                                 prefix: String = "") throws -> Open<FilePath> {
        // swiftlint:disable line_length
        let (fileDescriptor, path) = temporaryPathTemplate(tmpDir, prefix).withCString { ptr -> (FileDescriptor, String) in
            let mutablePtr = UnsafeMutablePointer(mutating: ptr)
            return (mkstemp(mutablePtr), String(cString: mutablePtr))
        }
        // swiftlint:enable line_length

        guard fileDescriptor != -1 else { throw MakeTemporaryError.getError() }

        // mkstemp(3) opens the file with readWrite permissions, the
        // .create/.exclusive flags (to ensure this process is the only
        // owner/creator of the uniquely generated tmp file), and a mode of
        // 0o0600
        return try FilePath(path).open(mode: .readPlus)
    }
}

extension DirectoryPath: TemporaryGeneratable {
    /**
     Creates a unique DirectoryPath with the specified prefix

     - Parameter base: The base directory where the temporary path will be placed
     - Parameter prefix: The directory name's prefix (before the randomly generated part of the path)
     - Returns: The opened temporary path

     - Throws: `CreateDirectoryError.permissionDenied` when the calling process does not have access to the path location
     - Throws: `CreateDirectoryError.quotaReached` when the user's quota of disk blocks or inodes on the filesystem has
                been exhausted
     - Throws: `CreateDirectoryError.noKernelMemory` when there is no memory available for creating the path
     - Throws: `CreateDirectoryError.fileSystemFull` when there is no available disk space for creating the path
     - Throws: `CreateDirectoryError.readOnlyFileSystem` when the filesystem is in read only mode and cannot create the
                path
     - Throws: `CreateDirectoryError.ioError` when an I/O error occurred while creating the inode for the
                pathIsRootDirectory
     - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
     - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file
                descriptors
     - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file
                descriptors
     - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
     */
    public static func temporary(base tmpDir: DirectoryPath = temporaryDirectory,
                                 prefix: String = "") throws -> Open<DirectoryPath> {
        // mkdtemp(s) require the last 6 characters to be X's in the template
        let path = temporaryPathTemplate(tmpDir, prefix).withCString {
            String(cString: mkdtemp(UnsafeMutablePointer(mutating: $0)))
        }
        guard !path.isEmpty else { throw CreateDirectoryError.getError() }

        return try DirectoryPath(path).open()
    }
}

public struct TemporaryOptions: OptionSet, ExpressibleByIntegerLiteral {
    public let rawValue: Int

    public static let deleteOnCompletion: TemporaryOptions = 1

    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(integerLiteral value: Int) { self.init(rawValue: value) }
}

public extension TemporaryGeneratable {
    @discardableResult
    static func temporary(base tmpDir: DirectoryPath = temporaryDirectory,
                          prefix: String = "",
                          options: TemporaryOptions = [],
                          closure: (_ opened: Open<Self>) throws -> Void) throws -> Self {
        let opened = try Self.temporary(base: tmpDir, prefix: prefix)

        try closure(opened)

        if options.contains(.deleteOnCompletion) {
            try Self._delete(opened)
        }

        return opened.path
    }
}

extension TemporaryGeneratable where Self: DirectoryEnumerable {
    // swiftlint:disable identifier_name
    public static func _delete(_ opened: Open<Self>) throws {
        var path = opened.path
        try path.recursiveDelete()
    }

    // swiftlint:enable identifier_name
}
