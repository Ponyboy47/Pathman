#if os(Linux)
import func Glibc.clearerr
import func Glibc.fflush
import func Glibc.fsync
import func Glibc.fwrite
import func Glibc.setvbuf
import func Glibc.fileno
#else
import func Darwin.clearerr
import func Darwin.fflush
import func Darwin.fsync
import func Darwin.fwrite
import func Darwin.setvbuf
import func Darwin.fileno
#endif

private let cWriteFile = fwrite
private let cClearError = clearerr
private let cSetBuffer = setvbuf
private let cFlushStream = fflush
private let cSyncFile = fsync

import ErrNo
import struct Foundation.Data

extension FilePath: BufferedWritableByOpened {
    /**
     Seeks to the specified offset and writes the data

     - Parameter buffer: The data to write to the path

     - Throws: `WriteError.wouldBlock` when the path was opened with the `.nonBlock` flag but the write operation would
                block
     - Throws: `WriteError.quotaReached` when the user's quota of disk blocks for the path have been exhausted
     - Throws: `WriteError.fileTooLarge` when an ettempt was made to write a file that exceeds the maximum defined file
                size for either the system or the process, or to write at a position past the maximum allowed offset
     - Throws: `WriteError.interruptedBySignal` when the API call was interrupted by a signal handler before any data
                was written
     - Throws: `WriteError.cannotWriteToFileDescriptor` when the underlying file descriptor is attached to a path which
                is unsuitable for writing or the file was opened with the `.direct` flag and either the buffer address,
                the byteCount, or the offset are not suitably aligned
     - Throws: `WriteError.ioError` when an I/O error occurred during the API call
     - Throws: `WriteError.fileSystemFull` when the file system is full
     - Throws: `WriteError.permissionDenied` when the operation was prevented because of a file seal (see fcntl(2))
     */
    @discardableResult
    public static func write(_ buffer: Data, to opened: Open<FilePath>) throws -> Int {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        // If the path has not been opened for writing
        guard opened.mayWrite else {
            throw WriteError.cannotWriteToFileStream
        }

        // If there's nothing to write
        guard !buffer.isEmpty else { return 0 }

        let countWritten = cWriteFile([UInt8](buffer), buffer.count, 1, descriptor)
        guard countWritten == 1 else {
            cClearError(descriptor)
            throw WriteError()
        }

        return buffer.count
    }

    public static func setBuffer(mode: BufferMode, to opened: Open<FilePath>) throws {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        let success: OptionInt
        if let buffer = mode.buffer {
            success = cSetBuffer(descriptor, buffer, mode.rawValue, mode.size)
        } else {
            success = cSetBuffer(descriptor, nil, mode.rawValue, mode.size)
        }

        guard success == 0 else {
            throw ErrNo.lastError
        }
    }

    public static func flush(stream opened: Open<FilePath>) throws {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        guard cFlushStream(descriptor) == 0 else { throw WriteError.getError() }
    }

    public static func sync(from opened: Open<FilePath>) throws {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        guard cSyncFile(fileno(descriptor)) != -1 else {
            throw SyncError.getError()
        }
    }

    public static func flush() throws {
        guard cFlushStream(nil) == 0 else { throw WriteError.getError() }
    }
}
