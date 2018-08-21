#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Open: Seekable where PathType: FilePath {
    public var offset: OSInt {
        get { return _offset }
        set {
            guard (try? seek(fromStart: newValue)) != nil else { return }
            _offset = newValue
        }
    }

    public var eof: Bool { return offset >= size }

    /**
    Moves the file offset from the beginning of the file by the specified number of bytes

    - Parameter bytes: The byte position to seek to in the file
    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    */
    @discardableResult
    public func seek(fromStart bytes: OSInt) throws -> OSInt {
        // If the offset is at the bytes already, then nothing would happen so
        // just go ahead and return
        guard offset != bytes else { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_SET)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        _offset = newOffset
        return offset
    }

    /**
    Moves the file offset from the end of the file by the specified number of bytes

    - Parameter bytes: The number of bytes to move from the end of the file
    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    */
    @discardableResult
    public func seek(fromEnd bytes: OSInt) throws -> OSInt {
        // If we're at the end of the file and we're not moving anywhere, go
        // ahead and return the offset
        if bytes == 0 && eof { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_END)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        _offset = newOffset
        return offset
    }

    /**
    Moves the file offset from the current position by the specified number of bytes

    - Parameter bytes: The number of bytes to move from the current file offset
    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    */
    @discardableResult
    public func seek(fromCurrent bytes: OSInt) throws -> OSInt {
        // If bytes is 0, then we're not moving anywhere and can just return
        // the current offset
        guard bytes != 0 else { return offset }

        let newOffset = lseek(fileDescriptor, bytes, SEEK_CUR)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        _offset = newOffset
        return offset
    }

    /**
    Moves the file offset back to the beginning of the file

    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    */
    @discardableResult
    public func rewind() throws -> OSInt {
        return try seek(fromStart: 0)
    }

    #if SEEK_DATA && SEEK_HOLE
    /**
    Moves the file offset to the next hole in the file greater than the specified offset number of bytes (as measured from the beginning of the file)

    - Parameter offset: The starting location in the file to begin looking for the next hole
    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    */
    @discardableResult
    public func seek(toNextHoleAfter offset: OSInt) throws -> OSInt {
        let newOffset = lseek(fileDescriptor, offset, SEEK_HOLE)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        _offset = newOffset
        return self.offset
    }

    /**
    Moves the file offset to the next location containing data

    - Parameter bytes: The starting locatin in the file to begin looking for data
    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    - Throws: `SeekError.noData` when there is no more data from the `offset` to the end of the file
    */
    @discardableResult
    public func seek(toNextDataAfter offset: OSInt) throws -> OSInt {
        let newOffset = lseek(fileDescriptor, offset, SEEK_DATA)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        _offset = newOffset
        return self.offset
    }
    #endif
}
