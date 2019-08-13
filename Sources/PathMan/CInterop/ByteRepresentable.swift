public protocol ByteRepresentable {
    var bytes: Int { get }
}

// swiftlint:disable identifier_name
public extension ByteRepresentable {
    /// Returns the number of bytes assuming self is kilobytes
    var kilobytes: Int { return bytes * 1024 }
    /// Returns the number of bytes assuming self is kilobytes
    var kb: Int { return kilobytes }
    /// Returns the number of bytes assuming self is megabytes
    var megabytes: Int { return kilobytes * 1024 }
    /// Returns the number of bytes assuming self is megabytes
    var mb: Int { return megabytes }
    /// Returns the number of bytes assuming self is gigabytes
    var gigabytes: Int { return megabytes * 1024 }
    /// Returns the number of bytes assuming self is gigabytes
    var gb: Int { return gigabytes }
    /// Returns the number of bytes assuming self is terabytes
    var terabytes: Int { return gigabytes * 1024 }
    /// Returns the number of bytes assuming self is terabytes
    var tb: Int { return terabytes }
    /// Returns the number of bytes assuming self is petabytes
    var petabytes: Int { return terabytes * 1024 }
    /// Returns the number of bytes assuming self is petabytes
    var pb: Int { return petabytes }
}

// swiftlint:enable identifier_name

extension Int: ByteRepresentable {
    public var bytes: Int { return self }
}

extension Int64: ByteRepresentable {
    public var bytes: Int { return Int(self) }
}

extension Float: ByteRepresentable {
    public var bytes: Int { return Int(self) }
}

extension Double: ByteRepresentable {
    public var bytes: Int { return Int(self) }
}
