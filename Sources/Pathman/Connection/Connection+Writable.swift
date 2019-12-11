import struct Foundation.Data

extension Connection: WritableWithFlags {
    public typealias WriteFlagsType = SendFlags

    @discardableResult
    public func write(_ buffer: Data, flags: SendFlags) throws -> Int {
        return try opened.write(buffer, flags: flags)
    }
}
