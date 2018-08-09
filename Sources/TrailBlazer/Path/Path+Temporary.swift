#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Protocol declaration for Paths that can generate and create a unique temporary path
public protocol TemporaryGeneratable: Path, Creatable {
    associatedtype TemporaryType: Path & Creatable
    static func temporary(prefix: String) throws -> Open<TemporaryType>
}

extension FilePath: TemporaryGeneratable {
    public typealias TemporaryType = FilePath

    /**
    Creates a unique FilePath with the specified prefix

    - Parameter prefix: The path's prefix
    - Returns: The opened temporary path

    - Throws: `MakeTemporaryError.alreadyExists` when the "unique" path that was generated already exists (hopefully shouldn't occur)
    - Throws: `CreateFileError.permissionDenied` when write access is not allowed to the path or if search permissions were denied on one of the components of the path
    - Throws: `CreateFileError.quotaReached` when the user's quota of disk blocks or inodes on the filesystem has been exhausted
    - Throws: `CreateFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `CreateFileError.noProcessFileDescriptors` when the calling process has no more available file descriptors
    - Throws: `CreateFileError.noSystemFileDescriptors` when the entire system has no more available file descriptors
    - Throws: `CreateFileError.noKernelMemory` when there is no memory available for creating the path
    - Throws: `CreateFileError.fileSystemFull` when there is no available disk space for creating the path
    - Throws: `CreateFileError.readOnlyFileSystem` when the filesystem is in read only mode and cannot create the path
    - Throws: `CreateFileError.lockedDevice` when the device where path exists is locked from writing
    - Throws: `CreateFileError.ioErrorCreatingPath` when an I/O error occurred while creating the inode for the path
    */
    public static func temporary(prefix: String = "") throws -> Open<TemporaryType> {
        let tmpDir: DirectoryPath

        // If this is set, it's the first place to check. macOS uses this
        // variable and it may or may not be set on Linux
        #if TMPDIR
        tmpDir = DirectoryPath(TMPDIR)!
        // This macro is referenced in C docs, but may or may not be set
        #elseif P_tmpdir
        tmpDir = DirectoryPath(P_tmpdir)!
        // Default to just /tmp if all else fails
        #else
        tmpDir = DirectoryPath("/tmp")!
        #endif

        // mkstemp(3) requires 6 consecutive X's in the template
        let (fileDescriptor, path) = "\(tmpDir.string)\(FilePath.separator)\(prefix)XXXXXX".withCString { (ptr) -> (FileDescriptor, String) in
            let mutablePtr = UnsafeMutablePointer(mutating: ptr)
            return (mkstemp(mutablePtr), String(cString: mutablePtr))
        }

        do {
            guard fileDescriptor != -1 else { throw MakeTemporaryError.getError() }
        } catch MakeTemporaryError.unknown { throw CreateFileError.getError() }

        let temporaryPath = tmpDir + (TemporaryType("\(path)") !! "Somehow, a random, uniquely generated path overwrote the \(TemporaryType.self) path that existed at \(path)")
        temporaryPath.fileDescriptor = fileDescriptor

        // mkstemp(3) opens the file with readWrite permissions and the
        // .create/.exclusive flags (to ensure this process is the only
        // owner/creator of the uniquely generated tmp file)
        temporaryPath.options = OpenFilePermissions.readWrite.rawValue | OpenFileFlags([.create, .exclusive]).rawValue
        // The file is give the following FileMode according to mkstemp(3)
        temporaryPath.mode = 0o0600

        return Open(temporaryPath)
    }
}

extension DirectoryPath: TemporaryGeneratable {
    public typealias TemporaryType = DirectoryPath

    /**
    Creates a unique DirectoryPath with the specified prefix

    - Parameter prefix: The path's prefix
    - Returns: The opened temporary path

    - Throws: `CreateDirectoryError.permissionDenied` when the calling process does not have access to the path location
    - Throws: `CreateDirectoryError.quotaReached` when the user's quota of disk blocks or inodes on the filesystem has been exhausted
    - Throws: `CreateDirectoryError.noKernelMemory` when there is no memory available for creating the path
    - Throws: `CreateDirectoryError.fileSystemFull` when there is no available disk space for creating the path
    - Throws: `CreateDirectoryError.readOnlyFileSystem` when the filesystem is in read only mode and cannot create the path
    - Throws: `CreateDirectoryError.ioError` when an I/O error occurred while creating the inode for the pathIsRootDirectory
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    */
    public static func temporary(prefix: String = "") throws -> Open<TemporaryType> {
        let tmpDir: DirectoryPath

        // If this is set, it's the first place to check. macOS uses this
        // variable and it may or may not be set on Linux
        #if TMPDIR
        tmpDir = DirectoryPath(TMPDIR)!
        // This macro is referenced in C docs, but may or may not be set
        #elseif P_tmpdir
        tmpDir = DirectoryPath(P_tmpdir)!
        // Default to just /tmp if all else fails
        #else
        tmpDir = DirectoryPath("/tmp")!
        #endif

        // mkdtemp(s) require the last 6 characters to be X's in the template
        let template = "\(tmpDir.string)\(DirectoryPath.separator)\(prefix)XXXXXX"

        guard let path = template.withCString({ mkdtemp(UnsafeMutablePointer(mutating: $0)) }) else { throw CreateDirectoryError.getError() }

        let dir = TemporaryType(String(cString: path)) !! "Somehow, a random, uniquely generated path overwrote the \(TemporaryType.self) that existed at \(path)"
        return try dir.open()
    }
}
