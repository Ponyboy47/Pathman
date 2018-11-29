#if os(Linux)
import func Glibc.recv
#else
import func Darwin.recv
#endif
/// The C function used to read data from an open socket
private let cReceiveData = recv

import struct Foundation.Data

/// Contains the buffer used for reading from a path
private var _buffers: [SocketPath: UnsafeMutablePointer<CChar>] = [:]
/// Tracks the sizes of the read buffers
private var _bufferSizes: [SocketPath: Int] = [:]

extension SocketPath: ReadableByOpenedWithFlags {
    public typealias ReadFlagsType = ReceiveFlags

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

    public static func read(bytes sizeToRead: ByteRepresentable,
                            flags: ReceiveFlags,
                            from opened: Open<SocketPath>) throws -> Data {
        let bytesToRead = sizeToRead.bytes

        // If we haven't allocated a buffer before, then allocate one now
        if opened.path.buffer == nil {
            opened.path.bufferSize = bytesToRead
        // If the buffer size is less than bytes we're going to read then reallocate the buffer
        } else if let bSize = opened.path.bufferSize, bSize < bytesToRead {
            opened.path.bufferSize = bytesToRead
        }
        // Reading the file returns the number of bytes read (or -1 if there was an error)
        let bytesRead = cReceiveData(opened.fileDescriptor, opened.path.buffer!, bytesToRead, 0)
        guard bytesRead != -1 else { throw ReadError.getError() }

        // Return the Data read from the descriptor
        return Data(bytes: opened.path.buffer!, count: bytesRead)
    }
}
