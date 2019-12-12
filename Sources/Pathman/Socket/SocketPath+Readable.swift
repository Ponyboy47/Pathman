#if os(Linux)
import func Glibc.recv
#else
import func Darwin.recv
#endif
/// The C function used to read data from an open socket
private let cReceiveData = recv

import struct Foundation.Data

extension SocketPath: ReadableByOpenedWithFlags {
    public typealias ReadFlagsType = ReceiveFlags

    public static func read(bytes sizeToRead: ByteRepresentable,
                            flags _: ReceiveFlags,
                            from opened: Open<SocketPath>) throws -> Data {
        guard let fileDescriptor = opened.fileDescriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        let bytesToRead = sizeToRead.bytes

        // If we haven't allocated a buffer before, then allocate one now
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bytesToRead)
        defer { buffer.deallocate() }
        // Reading the file returns the number of bytes read (or -1 if there was an error)
        let bytesRead = cReceiveData(fileDescriptor, buffer, bytesToRead, 0)
        guard bytesRead != -1 else { throw ReadError.getError() }

        // Return the Data read from the descriptor
        return Data(bytes: buffer, count: bytesRead)
    }
}
