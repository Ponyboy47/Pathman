#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Open: Seekable where PathType == FilePath {
    @discardableResult
    public func seek(fromStart bytes: Int) throws -> Int {
        guard offset != 0 && bytes != 0 else { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_SET)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func seek(fromEnd bytes: Int) throws -> Int {
        let newOffset = lseek(fileDescriptor, bytes, SEEK_END)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func seek(fromCurrent bytes: Int) throws -> Int {
        guard bytes != 0 else { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_CUR)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func rewind() throws -> Int {
        return try seek(fromStart: 0)
    }
}

