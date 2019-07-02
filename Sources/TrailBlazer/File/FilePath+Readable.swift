#if os(Linux)
import func Glibc.clearerr
import let Glibc.EOF
import func Glibc.feof
import func Glibc.fgetc
import func Glibc.fread
import func Glibc.getline
import func Glibc.ungetc
#else
import func Darwin.clearerr
import let Darwin.EOF
import func Darwin.feof
import func Darwin.fgetc
import func Darwin.fread
import func Darwin.getline
import func Darwin.ungetc
#endif
/// The C function used to read from an opened file descriptor
private let cReadFile = fread
private let cIsEOF = feof
private let cClearError = clearerr
private let cGetCharacter = fgetc
private let cUngetCharacter = ungetc
private let cGetLine = getline

import struct Foundation.Data

private var _buffers: [FilePath: UnsafeMutableRawPointer] = [:]
private var _bufferSizes: [FilePath: Int] = [:]

private var alignment = MemoryLayout<CChar>.alignment

extension FilePath: CharacterReadableByOpened, LineReadableByOpened, DefaultReadByteCount {
    /// The buffer used to store data read from a path
    var buffer: UnsafeMutableRawPointer? {
        get { return _buffers[self] }
        nonmutating set {
            buffer?.deallocate()

            guard let newBuffer = newValue else {
                _buffers.removeValue(forKey: self)
                return
            }

            _buffers[self] = newBuffer
        }
    }

    /// The size of the buffer used to store read data
    var bufferSize: Int? {
        get { return _bufferSizes[self] }
        nonmutating set {
            guard let newSize = newValue else {
                _bufferSizes.removeValue(forKey: self)
                return
            }

            buffer = UnsafeMutableRawPointer.allocate(byteCount: newSize, alignment: alignment)
            _bufferSizes[self] = newSize
        }
    }

    /**
     Read data from a descriptor

     - Parameter sizeToRead: The number of bytes to read from the descriptor
     - Returns: The Data read from the descriptor

     - Throws: `ReadError.wouldBlock` when the file was opened with the `.nonBlock` flag and the read operation would
               block
     - Throws: `ReadError.badFileDescriptor` when the underlying file descriptor is invalid or not opened
     - Throws: `ReadError.badBufferAddress` when the buffer points to a location outside you accessible address space
     - Throws: `ReadError.interruptedBySignal` when the API call was interrupted by a signal handler
     - Throws: `ReadError.cannotReadFileDescriptor` when the underlying file descriptor is attached to a path which is
               unsuitable for reading or the file was opened with the `.direct` flag and either the buffer addres, the
               byteCount, or the offset are not suitably aligned
     - Throws: `ReadError.ioError` when an I/O error occured during the API call
     */
    public static func read(bytes sizeToRead: ByteRepresentable = FilePath.defaultByteCount,
                            from opened: Open<FilePath>) throws -> Data {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        // If we don't have permissions to read then throw
        guard opened.mayRead else {
            throw ReadError.cannotReadFileStream
        }

        // If there's nothing to read, just return
        guard opened.size > 0 else { return Data() }

        let bytes = sizeToRead.bytes
        let bytesToRead = bytes > opened.size ? Int(opened.size) : bytes

        // If we haven't allocated a buffer before, then allocate one now
        if opened.path.buffer == nil {
            opened.path.bufferSize = bytesToRead
            // If the buffer size is less than bytes we're going to read then reallocate the buffer
        } else if let bSize = opened.path.bufferSize, bSize < bytesToRead {
            opened.path.bufferSize = bytesToRead
        }

        // Reading the file returns the number of bytes read (or 0 if there was an error or the eof was encountered)
        let bytesRead = cReadFile(opened.path.buffer!, 1, bytesToRead, descriptor)
        guard bytesRead != 0 || cIsEOF(descriptor) != 0 else {
            cClearError(descriptor)
            throw ReadError()
        }

        // Return the Data read from the descriptor
        return Data(bytes: opened.path.buffer!, count: bytesRead)
    }

    public static func nextLine(strippingNewline: Bool = true, from opened: Open<FilePath>) throws -> Data {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        var buffer: [UnsafeMutablePointer<CChar>?] = [nil]
        var size = 0
        let bytesRead = cGetLine(&buffer, &size, descriptor)

        // swiftlint:disable identifier_name
        guard let _bytes = buffer.first, let bytes = _bytes else { return Data() }
        // swiftlint:enable identifier_name
        return Data(bytes: bytes, count: strippingNewline ? bytesRead - 1 : bytesRead)
    }

    public static func nextCharacter(from opened: Open<FilePath>) throws -> Character {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        // If we don't have permissions to read then throw
        guard opened.mayRead else {
            throw ReadError.cannotReadFileStream
        }

        let char = cGetCharacter(descriptor)

        guard char != EOF else {
            throw ReadError()
        }

        guard let scalar = Unicode.Scalar(Int(char)) else {
            throw CharacterError.invalidUnicodeScalar(char)
        }

        return Character(scalar)
    }

    public static func ungetCharacter(_ character: Character, to opened: Open<FilePath>) throws {
        guard let descriptor = opened.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        // If we don't have permissions to write then throw
        guard opened.mayWrite else {
            throw WriteError.cannotWriteToFileStream
        }

        for char in character.unicodeScalars {
            let intValue = Int32(char.value)
            guard cUngetCharacter(intValue, descriptor) == intValue else {
                throw WriteError()
            }
        }
    }
}
