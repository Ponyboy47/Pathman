import Foundation
import ErrNo

#if os(Linux)
import Glibc
let cRead = Glibc.read
#else
import Darwin
let cRead = Darwin.read
#endif

// Protocol declaration of the functions and variables needed to be able to
// read from a file
public protocol Readable: Seekable {
    /// Seeks to the specified offset and returns the specified number of bytes
    func read(from offset: Offset, bytes byteCount: Int?) throws -> Data
    /// Seeks to the specified offset and returns the specified number of bytes in a string
    func read(from offset: Offset, bytes byteCount: Int?, encoding: String.Encoding) throws -> String?
}

public extension Readable {
    public func read(from offset: Offset = Offset(from: .current, size: 0), bytes byteCount: Int? = nil, encoding: String.Encoding = .utf8) throws -> String? {
        let data = try read(from: offset, bytes: byteCount)
        return String(data: data, encoding: encoding)
    }
}

public class FileReader: OpenFile, Readable {
    public var offset: Int = 0
    private var _buffer = UnsafeMutablePointer<CChar>.allocate(capacity: 0)
    private var _size: Int = 0

    public func read(from offset: Offset = Offset(from: .current, size: 0), bytes byteCount: Int? = nil) throws -> Data {
        try seek(offset)

        // Either read the specified number of bytes, or read the entire file
        let bytesToRead = byteCount ?? size

        if _size < bytesToRead {
            _buffer.deallocate()
		    _buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(bytesToRead))
            _size = bytesToRead
        }
        let bytesRead = cRead(fileDescriptor, _buffer, Int(bytesToRead))

        guard bytesRead != -1 else { throw ReadError.getError() }

        self.offset += bytesRead

        return Data(bytes: _buffer, count: bytesRead)
    }

    deinit {
        _buffer.deallocate()
    }
}

public extension FilePath {
    public var reader: FileReader? { return try? FileReader(self, permissions: .read) }
    public func read(from offset: Offset = Offset(from: .current, size: 0), bytes byteCount: Int? = nil) throws -> Data {
        return try FileReader(self, permissions: .read).read(from: offset, bytes: byteCount)
    }
    public func read(from offset: Offset = Offset(from: .current, size: 0), bytes byteCount: Int? = nil, encoding: String.Encoding = .utf8) throws -> String? {
        return try FileReader(self, permissions: .read).read(from: offset, bytes: byteCount, encoding: encoding)
    }
}
