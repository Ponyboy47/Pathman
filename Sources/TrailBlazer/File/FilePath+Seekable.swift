#if os(Linux)
import func Glibc.lseek
import let Glibc.SEEK_SET
import let Glibc.SEEK_END
import let Glibc.SEEK_CUR
#else
import func Darwin.lseek
import let Darwin.SEEK_SET
import let Darwin.SEEK_END
import let Darwin.SEEK_CUR
import let Darwin.SEEK_DATA
import let Darwin.SEEK_HOLE
#endif

extension FilePath: SeekableByOpened {
    /**
    Moves the file offset from the beginning of the file by the specified number of bytes

    - Parameter bytes: The byte position to seek to in the file
    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable
               device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    */
    @discardableResult
    public static func seek(fromStart bytes: OSOffsetInt, in opened: Open<FilePath>) throws -> OSOffsetInt {
        let newOffset = lseek(opened.fileDescriptor, bytes, SEEK_SET)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        return newOffset
    }

    /**
    Moves the file offset from the end of the file by the specified number of bytes

    - Parameter bytes: The number of bytes to move from the end of the file
    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable
               device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    */
    @discardableResult
    public static func seek(fromEnd bytes: OSOffsetInt, in opened: Open<FilePath>) throws -> OSOffsetInt {
        let newOffset = lseek(opened.fileDescriptor, bytes, SEEK_END)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        return newOffset
    }

    /**
    Moves the file offset from the current position by the specified number of bytes

    - Parameter bytes: The number of bytes to move from the current file offset
    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable
               device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    */
    @discardableResult
    public static func seek(fromCurrent bytes: OSOffsetInt, in opened: Open<FilePath>) throws -> OSOffsetInt {
        let newOffset = lseek(opened.fileDescriptor, bytes, SEEK_CUR)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        return newOffset
    }

    #if os(macOS)
    /**
    Moves the file offset to the next hole in the file greater than the specified offset number of bytes (as measured
    from the beginning of the file)

    - Parameter offset: The starting location in the file to begin looking for the next hole
    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable
               device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    */
    @discardableResult
    public static func seek(toNextHoleAfter offset: OSOffsetInt, in opened: Open<FilePath>) throws -> OSOffsetInt {
        let newOffset = lseek(opened.fileDescriptor, offset, SEEK_HOLE)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        return newOffset
    }

    /**
    Moves the file offset to the next location containing data

    - Parameter bytes: The starting locatin in the file to begin looking for data
    - Returns: The new file offset as measured in bytes from the beginning of the file

    - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a seekable
               device
    - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
    - Throws: `SeekError.noData` when there is no more data from the `offset` to the end of the file
    */
    @discardableResult
    public static func seek(toNextDataAfter offset: OSOffsetInt, in opened: Open<FilePath>) throws -> OSOffsetInt {
        let newOffset = lseek(opened.fileDescriptor, offset, SEEK_DATA)

        guard newOffset != -1 else {
            throw SeekError.getError()
        }

        return newOffset
    }
    #endif
}
