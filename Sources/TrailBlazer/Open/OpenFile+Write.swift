import Foundation
#if os(Linux)
import Glibc
private let cWriteFile = Glibc.write
#else
import Darwin
private let cWriteFile = Darwin.write
#endif

public protocol Writable: Openable, Seekable {
    func write(_ buffer: Data, at offset: Offset) throws
    func write(_ string: String, at offset: Offset, using encoding: String.Encoding) throws
}

public extension Writable {
    public func write(_ string: String, at offset: Offset = Offset(from: .current, bytes: 0), using encoding: String.Encoding = .utf8) throws {
        let data = try string.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        try write(data, at: offset)
    }
}

extension Open: Writable where PathType: FilePath {
    public func write(_ buffer: Data, at offset: Offset = Offset(from: .current, bytes: 0)) throws {
        if !OpenFileFlags(rawValue: options).contains(.append) {
            try seek(offset)
        } else {
            try seek(Offset(from: .end, bytes: 0))
        }

        guard cWriteFile(fileDescriptor, [UInt8](buffer), buffer.count) != -1 else { throw WriteError.getError() }
    }
}

public extension FilePath {
    public func write(_ buffer: Data, at offset: Offset = Offset(from: .current, bytes: 0)) throws {
        try self.open(permissions: .write).write(buffer, at: offset)
    }
    public func write(_ string: String, at offset: Offset = Offset(from: .current, bytes: 0), using encoding: String.Encoding = .utf8) throws {
        try self.open(permissions: .write).write(string, at: offset, using: encoding)
    }
}
