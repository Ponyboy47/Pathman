#if os(Linux)
import struct Glibc.FILE
import func Glibc.fileno
import let Glibc.stderr
import let Glibc.stdin
import let Glibc.stdout
let cStdout = Glibc.stdout
let cStderr = Glibc.stderr
let cStdin = Glibc.stdin
#else
import struct Darwin.FILE
import func Darwin.fileno
import let Darwin.stderr
import let Darwin.stdin
import let Darwin.stdout
let cStdout = Glibc.stdout
let cStderr = Glibc.stderr
let cStdin = Glibc.stdin
#endif

public let stdout: FileStream = {
    FileStream(descriptor: cStdout !! "No stdout stream!",
               fileDescriptor: fileno(cStdout),
               options: FilePath.OpenOptions(mode: "a+")) !! "Failed to set the opened file object"
}()

public let stderr: FileStream = {
    FileStream(descriptor: cStderr !! "No stderr stream!",
               fileDescriptor: fileno(cStderr),
               options: FilePath.OpenOptions(mode: "a+")) !! "Failed to set the opened file object"
}()

public let stdin: FileStream = {
    FileStream(descriptor: cStdin !! "No stdin stream!",
               fileDescriptor: fileno(cStdin),
               options: FilePath.OpenOptions(mode: "r")) !! "Failed to set the opened file object"
}()

extension Open where PathType == FilePath {
    static var stdout: FileStream { return TrailBlazer.stdout }
    static var stderr: FileStream { return TrailBlazer.stderr }
    static var stdin: FileStream { return TrailBlazer.stdin }
}

extension FilePath {
    static var stdout: FileStream { return TrailBlazer.stdout }
    static var stderr: FileStream { return TrailBlazer.stderr }
    static var stdin: FileStream { return TrailBlazer.stdin }
}
