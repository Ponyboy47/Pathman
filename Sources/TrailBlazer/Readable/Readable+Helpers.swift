import struct Foundation.Data

extension DefaultReadByteCount where Self: Readable {
    public func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead), encoding: encoding)
    }
}

extension DefaultReadByteCount where Self: Readable & Seekable {
    public func read(from offset: Offset, bytes bytesToRead: ByteRepresentable = Self.defaultByteCount) throws -> Data {
        try seek(offset)
        return try read(bytes: bytesToRead)
    }

    public func read(from offset: Offset,
                     bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
                     encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead), encoding: encoding)
    }
}
