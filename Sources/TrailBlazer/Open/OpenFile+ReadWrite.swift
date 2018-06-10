import Foundation

public class FileReaderWriter: OpenFile, Readable, Writable {
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

    public func write(_ buffer: Data, at offset: Offset = Offset(from: .current, size: 0)) throws {
        if !flags.contains(.append) {
            try seek(offset)
        }

        guard cWrite(fileDescriptor, [UInt8](buffer), buffer.count) != -1 else { throw WriteError.getError() }
    }

    deinit {
        _buffer.deallocate()
    }
}
