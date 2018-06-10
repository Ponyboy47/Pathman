import Foundation
#if os(Linux)
import Glibc
let cWrite = Glibc.write
#else
import Darwin
let cWrite = Darwin.write
#endif

public protocol Writable: Seekable {
    func write(_ buffer: Data, at offset: Offset) throws
    func write(_ string: String, at offset: Offset, using encoding: String.Encoding) throws
}

public extension Writable {
    public func write(_ string: String, at offset: Offset = Offset(from: .current, size: 0), using encoding: String.Encoding = .utf8) throws {
        guard let data = string.data(using: encoding) else {
            throw StringError.notConvertibleToData(using: encoding)
        }
        try write(data, at: offset)
    }
}

// Extension for FilePaths that allow the path to be written to
public class FileWriter: OpenFile, Writable {
    public var offset: Int = 0

    public func write(_ buffer: Data, at offset: Offset = Offset(from: .current, size: 0)) throws {
        if !flags.contains(.append) {
            try seek(offset)
        }

        guard cWrite(fileDescriptor, [UInt8](buffer), buffer.count) != -1 else { throw WriteError.getError() }
    }
}

public extension FilePath {
    public var writer: FileWriter? { return try? FileWriter(self, permissions: .write) }
    public func write(_ buffer: Data, at offset: Offset = Offset(from: .current, size: 0)) throws {
        try FileWriter(self, permissions: .write).write(buffer, at: offset)
    }
    public func write(_ string: String, at offset: Offset = Offset(from: .current, size: 0), using encoding: String.Encoding = .utf8) throws {
        try FileWriter(self, permissions: .write).write(string, at: offset, using: encoding)
    }
}
