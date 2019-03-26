import struct Foundation.Data

public extension DefaultReadByteCount where Self: Readable {
    func read(bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(bytes: bytesToRead), encoding: encoding)
    }
}

public extension DefaultReadByteCount where Self: Readable & Seekable {
    func read(from offset: Offset, bytes bytesToRead: ByteRepresentable = Self.defaultByteCount) throws -> Data {
        try seek(offset)
        return try read(bytes: bytesToRead)
    }

    func read(from offset: Offset,
              bytes bytesToRead: ByteRepresentable = Self.defaultByteCount,
              encoding: String.Encoding = .utf8) throws -> String? {
        return try String(data: read(from: offset, bytes: bytesToRead), encoding: encoding)
    }
}
