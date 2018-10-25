#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation

public struct CreateOptions: RawRepresentable, OptionSet, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt8
    public let rawValue: IntegerLiteralType

    /// Automatically creating any missing intermediate directories of the path
    public static let createIntermediates = CreateOptions(rawValue: 1 << 0)

    public init(rawValue: IntegerLiteralType) {
        self.init(integerLiteral: rawValue)
    }

    public init(integerLiteral value: IntegerLiteralType) {
        rawValue = value
    }
}

/// A Protocol for Path types that can be created
public protocol Creatable: Openable {
    // swiftlint:disable type_name
    associatedtype _OpenedType: Opened = Open<Self>
    // swiftlint:enable type_name
    /**
    Creates a path

    - Parameter mode: The FileMode (permissions) to use for the newly created path
    - Parameter forceMode: Whether or not to try and change the process's umask to guarentee that the FileMode is what
               you want (I've noticed that by default on Ubuntu, others' write access is disabled in the umask. Setting
               this to true should allow you to overcome this limitation)
    */
    @discardableResult
    mutating func create(mode: FileMode?, options: CreateOptions) throws -> _OpenedType
}

extension Creatable {
    mutating func create(mode: FileMode? = nil,
                         options: CreateOptions = [],
                         closure: (_ opened: _OpenedType) throws -> Void) throws {
        try closure(create(mode: mode, options: options))
    }
}

/// The FilePath Creatable conformance
extension FilePath: Creatable {
    /**
    Creates a FilePath

    - Parameter mode: The FileMode (permissions) to use for the newly created path
    - Parameter forceMode: Whether or not to try and change the process's umask to guarentee that the FileMode is what
               you want (I've noticed that by default on Ubuntu, others' write access is disabled in the umask. Setting
               this to true should allow you to overcome this limitation)

    - Throws: `CreateFileError.permissionDenied` when write access is not allowed to the path or if search permissions
               were denied on one of the components of the path
    - Throws: `CreateFileError.quotaReached` when the user's quota of disk blocks or inodes on the filesystem has been
               exhausted
    - Throws: `CreateFileError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `CreateFileError.interruptedBySignal` when the call was interrupted by a signal handler
    - Throws: `CreateFileError.tooManySymlinks` when too many symlinks were encountered while resolving the path name
    - Throws: `CreateFileError.noProcessFileDescriptors` when the calling process has no more available file descriptors
    - Throws: `CreateFileError.noSystemFileDescriptors` when the entire system has no more available file descriptors
    - Throws: `CreateFileError.pathnameTooLong` when the path exceeds PATH_MAX number of characters
    - Throws: `CreateFileError.noDevice` when the path points to a special file and no corresponding device exists
    - Throws: `CreateFileError.noRouteToPath` when the path cannot be resolved
    - Throws: `CreateFileError.noKernelMemory` when there is no memory available for creating the path
    - Throws: `CreateFileError.fileSystemFull` when there is no available disk space for creating the path
    - Throws: `CreateFileError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `CreateFileError.readOnlyFileSystem` when the filesystem is in read only mode and cannot create the path
    - Throws: `CreateFileError.pathBusy` when the path is an executable image which is currently being executed
    - Throws: `CreateFileError.lockedDevice` when the device where path exists is locked from writing
    - Throws: `CreateFileError.ioErrorCreatingPath` when an I/O error occurred while creating the inode for the path
    - Throws: `CreateFileError.pathExists` when creating a path that already exists
    */
    @discardableResult
    public mutating func create(mode: FileMode? = nil,
                                options: CreateOptions = []) throws -> Open<FilePath> {
        guard !exists else { throw CreateFileError.pathExists }

        // Create and immediately close any intermediates that don't exist when
        // the .createIntermediates options is used
        if options.contains(.createIntermediates) && !parent.exists {
            try parent.create(mode: mode, options: options)
        }

        // If the mode is not allowed by the umask, then we'll have to force it
        if let mode = mode {
            try self.change(permissions: mode)
        }

        return try open(permissions: .readWrite, flags: [.create, .exclusive], mode: mode)
    }
}

extension DirectoryPath: Creatable {
    /**
    Creates a DirectoryPath

    - Parameter mode: The FileMode (permissions) to use for the newly created path
    - Parameter forceMode: Whether or not to try and change the process's umask to guarentee that the FileMode is what
               you want (I've noticed that by default on Ubuntu, others' write access is disabled in the umask. Setting
               this to true should allow you to overcome this limitation)

    - Throws: `CreateDirectoryError.permissionDenied` when the calling process does not have access to the path location
    - Throws: `CreateDirectoryError.quotaReached` when the user's quota of disk blocks or inodes on the filesystem has
               been exhausted
    - Throws: `CreateDirectoryError.pathExists` when creating a path that already exists
    - Throws: `CreateDirectoryError.badAddress` when the path points to a location outside your accessible address space
    - Throws: `CreateDirectoryError.tooManySymlinks` when too many symlinks were encountered while resolving the path
               name
    - Throws: `CreateDirectoryError.pathnameTooLong` when the path exceeds PATH_MAX number of characters
    - Throws: `CreateDirectoryError.noRouteToPath` when the path cannot be resolved
    - Throws: `CreateDirectoryError.noKernelMemory` when there is no memory available for creating the path
    - Throws: `CreateDirectoryError.fileSystemFull` when there is no available disk space for creating the path
    - Throws: `CreateDirectoryError.pathComponentNotDirectory` when a component of the path is not a directory
    - Throws: `CreateDirectoryError.readOnlyFileSystem` when the filesystem is in read only mode and cannot create the
               path
    - Throws: `CreateDirectoryError.ioError` when an I/O error occurred while creating the inode for the
               pathIsRootDirectory
    - Throws: `CreateDirectoryError.pathIsRootDirectory` when the path points to the user's root directory
    */
    @discardableResult
    public mutating func create(mode: FileMode? = nil,
                                options: CreateOptions = []) throws -> Open<DirectoryPath> {
        guard !exists else { throw CreateDirectoryError.pathExists }

        // Create and immediately close any intermediates that don't exist when
        // the .createIntermediates options is used
        if options.contains(.createIntermediates) && !parent.exists {
            try parent.create(mode: mode, options: options)
        }

        guard mkdir(string, (mode ?? .allPermissions).rawValue) != -1 else {
            throw CreateDirectoryError.getError()
        }

        // If the mode is not allowed by the umask, then we'll have to force it
        if let mode = mode {
            try self.change(permissions: mode)
        }

        return try self.open()
    }
}

extension Creatable where _OpenedType: Writable {
    @discardableResult
    public mutating func create(mode: FileMode? = nil,
                                options: CreateOptions = [],
                                contents: Data) throws -> _OpenedType {
        let opened = try create(mode: mode, options: options)
        try opened.write(contents)
        return opened
    }

    @discardableResult
    public mutating func create(mode: FileMode? = nil,
                                options: CreateOptions = [],
                                contents: String,
                                using encoding: String.Encoding = .utf8) throws -> _OpenedType {
        let data = try contents.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try create(mode: mode, options: options, contents: data)
    }
}
