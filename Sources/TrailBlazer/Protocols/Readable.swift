import struct Foundation.Data

public protocol Readable {
    func read(bytes bytesToRead: ByteRepresentable) throws -> Data
}

public protocol _ReadsWithFlags {
    associatedtype ReadFlagsType: OptionSet
    static var emptyReadFlags: ReadFlagsType { get }
}

public protocol ReadableWithFlags: Readable, _ReadsWithFlags {
    func read(bytes bytesToRead: ByteRepresentable, flags: ReadFlagsType) throws -> Data
}

public protocol DefaultReadByteCount {
    static var defaultByteCount: ByteRepresentable { get }
}

public protocol ReadableByOpened: Openable {
    static func read(bytes: ByteRepresentable, from opened: Open<Self>) throws -> Data
}

public protocol ReadableByOpenedWithFlags: ReadableByOpened, _ReadsWithFlags {
    static func read(bytes bytesToRead: ByteRepresentable, flags: ReadFlagsType, from opened: Open<Self>) throws -> Data
}

public protocol CharacterReadable: Readable {
    func nextCharacter() throws -> Character
    func ungetCharacter(_ character: Character) throws
}

public protocol CharacterReadableByOpened: ReadableByOpened {
    static func nextCharacter(from opened: Open<Self>) throws -> Character
    static func ungetCharacter(_ character: Character, to opened: Open<Self>) throws
}
