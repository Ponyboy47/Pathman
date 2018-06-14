#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Open: Seekable where PathType == FilePath {
    @discardableResult
    public func seek(fromStart bytes: Int64) throws -> Int64 {
        guard offset != 0 && bytes != 0 else { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_SET)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func seek(fromEnd bytes: Int64) throws -> Int64 {
        let newOffset = lseek(fileDescriptor, bytes, SEEK_END)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func seek(fromCurrent bytes: Int64) throws -> Int64 {
        guard bytes != 0 else { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_CUR)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func rewind() throws -> Int64 {
        return try seek(fromStart: 0)
    }

    #if os(macOS)
    @discardableResult
    public func seek(toNextHoleFrom offset: Int64) throws -> Int64 {
        let newOffset = lseek(fileDescriptor, offset, SEEK_HOLE)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        self.offset = newOffset
        return self.offset
    }

    @discardableResult
    public func seek(toNextDataFrom offset: Int64) throws -> Int64 {
        let newOffset = lseek(fileDescriptor, offset, SEEK_DATA)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        self.offset = newOffset
        return self.offset
    }
    #endif
}

