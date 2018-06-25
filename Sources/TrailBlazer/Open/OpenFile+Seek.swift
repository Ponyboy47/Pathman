#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Open: Seekable where PathType == FilePath {
    @discardableResult
    public func seek(fromStart bytes: OSInt) throws -> OSInt {
        guard offset != 0 && bytes != 0 else { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_SET)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func seek(fromEnd bytes: OSInt) throws -> OSInt {
        let newOffset = lseek(fileDescriptor, bytes, SEEK_END)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func seek(fromCurrent bytes: OSInt) throws -> OSInt {
        guard bytes != 0 else { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_CUR)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        offset = newOffset
        return offset
    }

    @discardableResult
    public func rewind() throws -> OSInt {
        return try seek(fromStart: 0)
    }

    #if os(macOS)
    @discardableResult
    public func seek(toNextHoleFrom offset: OSInt) throws -> OSInt {
        let newOffset = lseek(fileDescriptor, offset, SEEK_HOLE)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        self.offset = newOffset
        return self.offset
    }

    @discardableResult
    public func seek(toNextDataFrom offset: OSInt) throws -> OSInt {
        let newOffset = lseek(fileDescriptor, offset, SEEK_DATA)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        self.offset = newOffset
        return self.offset
    }
    #endif
}

