#if os(Linux)
import func Glibc.write
#else
import func Darwin.write
#endif
private let cWriteFile = write

import struct Foundation.Data

extension FilePath: WritableByOpened {
    /**
     Seeks to the specified offset and writes the data

     - Parameter buffer: The data to write to the path

     - Throws: `WriteError.wouldBlock` when the path was opened with the `.nonBlock` flag but the write operation would
                block
     - Throws: `WriteError.quotaReached` when the user's quota of disk blocks for the path have been exhausted
     - Throws: `WriteError.fileTooLarge` when an ettempt was made to write a file that exceeds the maximum defined file
                size for either the system or the process, or to write at a position past the maximum allowed offset
     - Throws: `WriteError.interruptedBySignal` when the API call was interrupted by a signal handler before any data was
                written
     - Throws: `WriteError.cannotWriteToFileDescriptor` when the underlying file descriptor is attached to a path which
                is unsuitable for writing or the file was opened with the `.direct` flag and either the buffer address,
                the byteCount, or the offset are not suitably aligned
     - Throws: `WriteError.ioError` when an I/O error occurred during the API call
     - Throws: `WriteError.fileSystemFull` when the file system is full
     - Throws: `WriteError.permissionDenied` when the operation was prevented because of a file seal (see fcntl(2))
     */
    public static func write(_ buffer: Data, to opened: Open<FilePath>) throws {
        // If the path has not been opened for writing
        guard opened.mayWrite else {
            throw WriteError.cannotWriteToFileDescriptor
        }

        guard cWriteFile(opened.fileDescriptor, [UInt8](buffer), buffer.count) != -1 else {
            throw WriteError.getError()
        }
    }
}
