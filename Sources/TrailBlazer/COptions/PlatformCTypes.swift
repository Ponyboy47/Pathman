#if os(Linux)
import Glibc
public typealias OSOffsetInt = Int
public typealias OSUInt = UInt32
#else
import Darwin
public typealias OSOffsetInt = Int64
public typealias OSUInt = UInt16
#endif
public typealias OptionInt = Int32
public typealias FileDescriptor = Int32
