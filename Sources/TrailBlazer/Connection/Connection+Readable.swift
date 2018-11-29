import struct Foundation.Data

/// Contains the buffer used for reading from a path
private var _buffers: [Int: UnsafeMutablePointer<CChar>] = [:]
/// Tracks the sizes of the read buffers
private var _bufferSizes: [Int: Int] = [:]

extension Connection: ReadableWithFlags, DefaultReadByteCount {
    public typealias ReadFlagsType = ReceiveFlags

    public func read(bytes sizeToRead: ByteRepresentable = Connection.defaultByteCount,
                     flags: ReceiveFlags) throws -> Data {
        return try opened.read(bytes: sizeToRead, flags: flags)
    }
}
