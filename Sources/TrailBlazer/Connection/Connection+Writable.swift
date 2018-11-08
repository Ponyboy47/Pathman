import struct Foundation.Data

extension Connection: WritableWithFlags {
    public typealias WriteFlagsType = SendFlags

    public func write(_ buffer: Data, flags: SendFlags) throws {
        try opened.write(buffer, flags: flags)
    }
}
