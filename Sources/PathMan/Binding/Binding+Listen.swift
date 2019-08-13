#if os(Linux)
import func Glibc.listen
#else
import func Darwin.listen
#endif
private let cListenToSocket = listen

public extension Binding {
    func listen(maxQueued: OptionInt) throws {
        guard let descriptor = self.descriptor else {
            throw ClosedDescriptorError.alreadyClosed
        }
        isListening = cListenToSocket(descriptor, maxQueued) == 0

        guard isListening else {
            throw ListenError.getError()
        }
    }
}
