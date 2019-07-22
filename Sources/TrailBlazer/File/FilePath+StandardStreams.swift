#if os(Linux)
import struct Glibc.FILE
import func Glibc.fileno
import let Glibc.stderr
import let Glibc.stdin
import let Glibc.stdout
#else
import struct Darwin.FILE
import func Darwin.fileno
import let Darwin.stderr
import let Darwin.stdin
import let Darwin.stdout
#endif

extension Open where PathType == FilePath {
    static var stdout: FileStream { return openStdout() }
    static var stderr: FileStream { return openStderr() }
    static var stdin: FileStream { return openStdin() }
}

extension FilePath {
    static var stdout: FileStream { return openStdout() }
    static var stderr: FileStream { return openStderr() }
    static var stdin: FileStream { return openStdin() }
}

private func openStdout() -> FileStream {
    return FileStream(FilePath("")!,
                      descriptor: stdout,
                      fileDescriptor: fileno(stdout),
                      options: FilePath.OpenOptions(mode: "a+")) !! "Failed to set the opened file object"
}

private func openStderr() -> FileStream {
    return FileStream(FilePath("")!,
                      descriptor: stderr,
                      fileDescriptor: fileno(stderr),
                      options: FilePath.OpenOptions(mode: "a+")) !! "Failed to set the opened file object"
}

private func openStdin() -> FileStream {
    return FileStream(FilePath("")!,
                      descriptor: stdin,
                      fileDescriptor: fileno(stdin),
                      options: FilePath.OpenOptions(mode: "a+")) !! "Failed to set the opened file object"
}
