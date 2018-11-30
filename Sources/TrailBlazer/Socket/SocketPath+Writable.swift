#if os(Linux)
import func Glibc.send
#else
import func Darwin.send
#endif
/// C function to send data across a socket
private let cSendData = send

import struct Foundation.Data

extension SocketPath: WritableByOpenedWithFlags {
    public typealias WriteFlagsType = SendFlags
    public typealias WriteReturnType = Data?

    public static func write(_ buffer: Data, flags: SendFlags, to opened: Open<SocketPath>) throws -> Data? {
        let bytesSent = cSendData(opened.fileDescriptor, [UInt8](buffer), buffer.count, flags.rawValue)
        guard bytesSent != -1 else {
            throw SendError.getError()
        }

        return bytesSent == buffer.count ? nil : buffer[bytesSent...]
    }
}