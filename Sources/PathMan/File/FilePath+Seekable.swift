#if os(Linux)
import func Glibc.clearerr
import func Glibc.fseeko
import func Glibc.ftello
import let Glibc.SEEK_CUR
import let Glibc.SEEK_END
import let Glibc.SEEK_SET
#else
import func Darwin.clearerr
import func Darwin.fseeko
import func Darwin.ftello
import let Darwin.SEEK_CUR
import let Darwin.SEEK_END
import let Darwin.SEEK_SET
#endif

extension FilePath: SeekableByOpened {
    public static func getCurrentOffset(in opened: Open<FilePath>) throws -> OSOffsetInt {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        let offset = ftello(descriptor)
        guard offset != -1 else {
            defer { clearerr(descriptor) }
            throw SeekError.getError()
        }

        return offset
    }

    /**
     Moves the file offset from the beginning of the file by the specified number of bytes

     - Parameter bytes: The byte position to seek to in the file

     - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a
                seekable device
     - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
     */
    public static func seek(fromStart bytes: OSOffsetInt, in opened: Open<FilePath>) throws {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        guard fseeko(descriptor, bytes, SEEK_SET) != -1 else {
            defer { clearerr(descriptor) }
            throw SeekError.getError()
        }
    }

    /**
     Moves the file offset from the end of the file by the specified number of bytes

     - Parameter bytes: The number of bytes to move from the end of the file

     - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a
                seekable device
     - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
     */
    public static func seek(fromEnd bytes: OSOffsetInt, in opened: Open<FilePath>) throws {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        guard fseeko(descriptor, bytes, SEEK_END) != -1 else {
            defer { clearerr(descriptor) }
            throw SeekError.getError()
        }
    }

    /**
     Moves the file offset from the current position by the specified number of bytes

     - Parameter bytes: The number of bytes to move from the current file offset

     - Throws: `SeekError.invalidOffset` when the resulting file offset would be negative or beyond the end of a
                seekable device
     - Throws: `SeekError.offsetTooLarge` when the resulting file offset cannot be represented in an off_t
     */
    public static func seek(fromCurrent bytes: OSOffsetInt, in opened: Open<FilePath>) throws {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        guard fseeko(descriptor, bytes, SEEK_CUR) != -1 else {
            defer { clearerr(descriptor) }
            throw SeekError.getError()
        }
    }
}
