#if os(Linux)
import func Glibc.read
#else
import func Darwin.read
#endif
/// The C function used to read from an opened file descriptor
private let cReadFile = read

import struct Foundation.Data

private var _buffers: [FilePath: UnsafeMutablePointer<CChar>] = [:]
private var _bufferSizes: [FilePath: Int] = [:]

extension FilePath: ReadableByOpened, Readable, DefaultReadByteCount {
    /// The buffer used to store data read from a path
    var buffer: UnsafeMutablePointer<CChar>? {
        get { return _buffers[self] }
        nonmutating set {
            if let bSize = bufferSize {
                buffer?.deinitialize(count: bSize)
            }
            buffer?.deallocate()

            guard let newBuffer = newValue else {
                _buffers.removeValue(forKey: self)
                return
            }

            _buffers[self] = newBuffer
        }
    }

    /// The size of the buffer used to store read data
    var bufferSize: Int? {
        get { return _bufferSizes[self] }
        nonmutating set {
            guard let newSize = newValue else {
                _bufferSizes.removeValue(forKey: self)
                return
            }

            buffer = UnsafeMutablePointer<CChar>.allocate(capacity: newSize)
            _bufferSizes[self] = newSize
        }
    }

    /**
    Read data from a descriptor

    - Parameter sizeToRead: The number of bytes to read from the descriptor
    - Returns: The Data read from the descriptor

    - Throws: `ReadError.wouldBlock` when the file was opened with the `.nonBlock` flag and the read operation would
              block
    - Throws: `ReadError.badFileDescriptor` when the underlying file descriptor is invalid or not opened
    - Throws: `ReadError.badBufferAddress` when the buffer points to a location outside you accessible address space
    - Throws: `ReadError.interruptedBySignal` when the API call was interrupted by a signal handler 
    - Throws: `ReadError.cannotReadFileDescriptor` when the underlying file descriptor is attached to a path which is
              unsuitable for reading or the file was opened with the `.direct` flag and either the buffer addres, the
              byteCount, or the offset are not suitably aligned
    - Throws: `ReadError.ioError` when an I/O error occured during the API call
    */
    public static func read(bytes sizeToRead: ByteRepresentable = FilePath.defaultByteCount, from opened: Open<FilePath>) throws -> Data {
        guard opened.mayRead else {
            throw ReadError.cannotReadFileDescriptor
        }
        let bytes = sizeToRead.bytes

        let bytesToRead = bytes > opened.size ? Int(opened.size) : bytes

        // If we haven't allocated a buffer before, then allocate one now
        if opened.path.buffer == nil {
            opened.path.bufferSize = bytesToRead
        // If the buffer size is less than bytes we're going to read then reallocate the buffer
        } else if let bSize = opened.path.bufferSize, bSize < bytesToRead {
            opened.path.bufferSize = bytesToRead
        }
        // Reading the file returns the number of bytes read (or -1 if there was an error)
        let bytesRead = cReadFile(opened.fileDescriptor, opened.path.buffer!, bytesToRead)
        guard bytesRead != -1 else { throw ReadError.getError() }

        // Return the Data read from the descriptor
        return Data(bytes: opened.path.buffer!, count: bytesRead)
    }
}
