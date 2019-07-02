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
        guard var descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        let offset = withUnsafeMutablePointer(to: &descriptor) { ftello($0) }
        guard offset != -1 else {
            defer { withUnsafeMutablePointer(to: &descriptor) { clearerr($0) } }
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
        guard var descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        let offset = withUnsafeMutablePointer(to: &descriptor) { fseeko($0, bytes, SEEK_SET) }
        guard offset != -1 else {
            defer { withUnsafeMutablePointer(to: &descriptor) { clearerr($0) } }
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
        guard var descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        let offset = withUnsafeMutablePointer(to: &descriptor) { fseeko($0, bytes, SEEK_END) }
        guard offset != -1 else {
            defer { withUnsafeMutablePointer(to: &descriptor) { clearerr($0) } }
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
        guard var descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        let offset = withUnsafeMutablePointer(to: &descriptor) { fseeko($0, bytes, SEEK_CUR) }
        guard offset != -1 else {
            defer { withUnsafeMutablePointer(to: &descriptor) { clearerr($0) } }
            throw SeekError.getError()
        }
    }
}
