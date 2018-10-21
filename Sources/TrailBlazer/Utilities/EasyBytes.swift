public extension BinaryInteger {
    /// Returns the number of bytes assuming self is kilobytes
    public var kilobytes: Int { return Int(self * 1024) }
    /// Returns the number of bytes assuming self is kilobytes
    public var kb: Int { return kilobytes }
    /// Returns the number of bytes assuming self is megabytes
    public var megabytes: Int { return kilobytes * 1024 }
    /// Returns the number of bytes assuming self is megabytes
    public var mb: Int { return megabytes }
    /// Returns the number of bytes assuming self is gigabytes
    public var gigabytes: Int { return megabytes * 1024 }
    /// Returns the number of bytes assuming self is gigabytes
    public var gb: Int { return gigabytes }
    /// Returns the number of bytes assuming self is terabytes
    public var terabytes: Int { return gigabytes * 1024 }
    /// Returns the number of bytes assuming self is terabytes
    public var tb: Int { return terabytes }
    /// Returns the number of bytes assuming self is petabytes
    public var petabytes: Int { return terabytes * 1024 }
    /// Returns the number of bytes assuming self is petabytes
    public var pb: Int { return petabytes }
}

public extension BinaryFloatingPoint {
    /// Returns the number of bytes assuming self is kilobytes
    public var kilobytes: Int { return Int(self * 1024.0) }
    /// Returns the number of bytes assuming self is kilobytes
    public var kb: Int { return kilobytes }
    /// Returns the number of bytes assuming self is megabytes
    public var megabytes: Int { return kilobytes * 1024 }
    /// Returns the number of bytes assuming self is megabytes
    public var mb: Int { return megabytes }
    /// Returns the number of bytes assuming self is gigabytes
    public var gigabytes: Int { return megabytes * 1024 }
    /// Returns the number of bytes assuming self is gigabytes
    public var gb: Int { return gigabytes }
    /// Returns the number of bytes assuming self is terabytes
    public var terabytes: Int { return gigabytes * 1024 }
    /// Returns the number of bytes assuming self is terabytes
    public var tb: Int { return terabytes }
    /// Returns the number of bytes assuming self is petabytes
    public var petabytes: Int { return terabytes * 1024 }
    /// Returns the number of bytes assuming self is petabytes
    public var pb: Int { return petabytes }
}
