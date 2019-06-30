extension Open: Seekable where PathType: SeekableByOpened {
    public func getCurrentOffset() throws -> OSOffsetInt {
        return try PathType.getCurrentOffset(in: self)
    }

    public func seek(fromStart bytes: OSOffsetInt) throws {
        try PathType.seek(fromStart: bytes, in: self)
    }

    public func seek(fromEnd bytes: OSOffsetInt) throws {
        try PathType.seek(fromEnd: bytes, in: self)
    }

    public func seek(fromCurrent bytes: OSOffsetInt) throws {
        try PathType.seek(fromCurrent: bytes, in: self)
    }
}
