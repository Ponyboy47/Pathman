#if os(Linux)
import typealias Glibc.blksize_t
import typealias Glibc.dev_t
import typealias Glibc.gid_t
import typealias Glibc.ino_t
import typealias Glibc.uid_t

public typealias OSOffsetInt = Int
public typealias OSUInt = UInt32
#else
import typealias Darwin.blksize_t
import typealias Darwin.dev_t
import typealias Darwin.gid_t
import typealias Darwin.ino_t
import typealias Darwin.uid_t

public typealias OSOffsetInt = Int64
public typealias OSUInt = UInt16
#endif

public typealias OptionInt = Int32
public typealias FileDescriptor = Int32

public typealias UID = uid_t
public typealias GID = gid_t

public typealias DeviceID = dev_t
public typealias Inode = ino_t
public typealias BlockSize = blksize_t
