extension Open: Seekable where PathType: SeekableByOpened {
    @discardableResult
    public func seek(fromStart bytes: OSOffsetInt) throws -> OSOffsetInt {
        return try PathType.seek(fromStart: bytes, in: self)
    }

    @discardableResult
    public func seek(fromEnd bytes: OSOffsetInt) throws -> OSOffsetInt {
        return try PathType.seek(fromEnd: bytes, in: self)
    }

    @discardableResult
    public func seek(fromCurrent bytes: OSOffsetInt) throws -> OSOffsetInt {
        return try PathType.seek(fromCurrent: bytes, in: self)
    }

    // These are available on the following filesystems:
    // Btrfs, OCFS, XFS, ext4, tmpfs, and the macOS filesystem
    // Unfortunately checking the value does not work
    #if os(macOS)
    @discardableResult
    public func seek(toNextHoleAfter offset: OSOffsetInt) throws -> OSOffsetInt {
        return try PathType.seek(toNextHoleAfter: offset, in: self)
    }

    @discardableResult
    public func seek(toNextDataAfter offset: OSOffsetInt) throws -> OSOffsetInt {
        return try PathType.seek(toNextDataAfter: offset, in: self)
    }
    #endif
}
