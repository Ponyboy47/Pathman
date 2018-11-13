#if os(Linux)
import func Glibc.listen
#else
import func Darwin.listen
#endif
private let cListenToSocket = listen

extension Binding {
    public func listen(max: OptionInt) throws {
        isListening = cListenToSocket(fileDescriptor, max) == 0

        guard isListening else {
            throw ListenError.getError()
        }
    }
}
