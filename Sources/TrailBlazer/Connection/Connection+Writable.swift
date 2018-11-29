import struct Foundation.Data

extension Connection: WritableWithFlags {
    public typealias WriteFlagsType = SendFlags
    public typealias WriteReturnType = Data?

    public func write(_ buffer: Data, flags: SendFlags) throws -> Data? {
        return try opened.write(buffer, flags: flags)
    }
}
