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

    @discardableResult
    public static func write(_ buffer: Data, flags: SendFlags, to opened: Open<SocketPath>) throws -> Int {
        guard let fileDescriptor = opened.fileDescriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }

        let bytesSent = cSendData(fileDescriptor, [UInt8](buffer), buffer.count, flags.rawValue)
        guard bytesSent != -1 else {
            throw SendError.getError()
        }

        return bytesSent
    }
}
