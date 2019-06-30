#if os(Linux)
import func Glibc.listen
#else
import func Darwin.listen
#endif
private let cListenToSocket = listen

public extension Binding {
    func listen(maxQueued: OptionInt) throws {
        guard let fileDescriptor = self.fileDescriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }
        isListening = cListenToSocket(fileDescriptor, maxQueued) == 0

        guard isListening else {
            throw ListenError.getError()
        }
    }
}
