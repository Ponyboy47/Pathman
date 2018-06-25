import Foundation
import ErrNo

#if os(Linux)
import Glibc
private let cReadFile = Glibc.read
#else
import Darwin
private let cReadFile = Darwin.read
#endif

// Protocol declaration of the functions and variables needed to be able to
// read from a file
public protocol Readable: Openable, Seekable {
    /// Seeks to the specified offset and returns the specified number of bytes
    func read(from offset: Offset, bytes byteCount: OSInt?) throws -> Data
    /// Seeks to the specified offset and returns the specified number of bytes in a string
    func read(from offset: Offset, bytes byteCount: OSInt?, encoding: String.Encoding) throws -> String?
}

public extension Readable {
    public func read(from offset: Offset = Offset(from: .current, bytes: 0), bytes byteCount: OSInt? = nil, encoding: String.Encoding = .utf8) throws -> String? {
        let data = try read(from: offset, bytes: byteCount)
        return String(data: data, encoding: encoding)
    }
}

extension Open: Readable where PathType == FilePath {
    public func read(from offset: Offset = Offset(from: .current, bytes: 0), bytes byteCount: OSInt? = nil) throws -> Data {
        try seek(offset)

        // Either read the specified number of bytes, or read the entire file
        let bytesToRead = byteCount ?? size

        if (bufferSize ?? 0) < bytesToRead {
            buffer?.deallocate()
		    buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(bytesToRead))
            bufferSize = bytesToRead
        }
        let bytesRead = cReadFile(fileDescriptor, buffer!, Int(bytesToRead))

        guard bytesRead != -1 else { throw ReadError.getError() }

        self.offset += OSInt(bytesRead)

        return Data(bytes: buffer!, count: bytesRead)
    }
}

public extension FilePath {
    public func read(from offset: Offset = Offset(from: .current, bytes: 0), bytes byteCount: OSInt? = nil) throws -> Data {
        return try Open(self, permissions: .read).read(from: offset, bytes: byteCount)
    }
    public func read(from offset: Offset = Offset(from: .current, bytes: 0), bytes byteCount: OSInt? = nil, encoding: String.Encoding = .utf8) throws -> String? {
        return try Open(self, permissions: .read).read(from: offset, bytes: byteCount, encoding: encoding)
    }
}
