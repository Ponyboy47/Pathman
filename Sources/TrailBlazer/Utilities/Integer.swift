public extension BinaryInteger {
    /// Returns the number of bytes assuming self is kilobytes
    public var kilobytes: OSInt { return OSInt(self * 1024) }
    /// Returns the number of bytes assuming self is kilobytes
    public var kb: OSInt { return kilobytes }
    /// Returns the number of bytes assuming self is megabytes
    public var megabytes: OSInt { return kilobytes * 1024 }
    /// Returns the number of bytes assuming self is megabytes
    public var mb: OSInt { return megabytes }
    /// Returns the number of bytes assuming self is gigabytes
    public var gigabytes: OSInt { return megabytes * 1024 }
    /// Returns the number of bytes assuming self is gigabytes
    public var gb: OSInt { return gigabytes }
    /// Returns the number of bytes assuming self is terabytes
    public var terabytes: OSInt { return gigabytes * 1024 }
    /// Returns the number of bytes assuming self is terabytes
    public var tb: OSInt { return terabytes }
    /// Returns the number of bytes assuming self is petabytes
    public var petabytes: OSInt { return terabytes * 1024 }
    /// Returns the number of bytes assuming self is petabytes
    public var pb: OSInt { return petabytes }
}

public extension Double {
    /// Returns the number of bytes assuming self is kilobytes
    public var kilobytes: OSInt { return OSInt(self * 1024.0) }
    /// Returns the number of bytes assuming self is kilobytes
    public var kb: OSInt { return kilobytes }
    /// Returns the number of bytes assuming self is megabytes
    public var megabytes: OSInt { return kilobytes * 1024 }
    /// Returns the number of bytes assuming self is megabytes
    public var mb: OSInt { return megabytes }
    /// Returns the number of bytes assuming self is gigabytes
    public var gigabytes: OSInt { return megabytes * 1024 }
    /// Returns the number of bytes assuming self is gigabytes
    public var gb: OSInt { return gigabytes }
    /// Returns the number of bytes assuming self is terabytes
    public var terabytes: OSInt { return gigabytes * 1024 }
    /// Returns the number of bytes assuming self is terabytes
    public var tb: OSInt { return terabytes }
    /// Returns the number of bytes assuming self is petabytes
    public var petabytes: OSInt { return terabytes * 1024 }
    /// Returns the number of bytes assuming self is petabytes
    public var pb: OSInt { return petabytes }
}

public extension Float {
    /// Returns the number of bytes assuming self is kilobytes
    public var kilobytes: OSInt { return OSInt(self * 1024.0) }
    /// Returns the number of bytes assuming self is kilobytes
    public var kb: OSInt { return kilobytes }
    /// Returns the number of bytes assuming self is megabytes
    public var megabytes: OSInt { return kilobytes * 1024 }
    /// Returns the number of bytes assuming self is megabytes
    public var mb: OSInt { return megabytes }
    /// Returns the number of bytes assuming self is gigabytes
    public var gigabytes: OSInt { return megabytes * 1024 }
    /// Returns the number of bytes assuming self is gigabytes
    public var gb: OSInt { return gigabytes }
    /// Returns the number of bytes assuming self is terabytes
    public var terabytes: OSInt { return gigabytes * 1024 }
    /// Returns the number of bytes assuming self is terabytes
    public var tb: OSInt { return terabytes }
    /// Returns the number of bytes assuming self is petabytes
    public var petabytes: OSInt { return terabytes * 1024 }
    /// Returns the number of bytes assuming self is petabytes
    public var pb: OSInt { return petabytes }
}
