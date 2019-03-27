#if os(Linux)
import var Glibc.errno
import func Glibc.geteuid
import func Glibc.getgrgid
import func Glibc.getgrnam
import func Glibc.getpwnam
import func Glibc.getpwuid
import struct Glibc.group
import struct Glibc.passwd
#else
import var Darwin.errno
import func Darwin.geteuid
import func Darwin.getgrgid
import func Darwin.getgrnam
import func Darwin.getpwnam
import func Darwin.getpwuid
import struct Darwin.group
import struct Darwin.passwd
#endif

public typealias Passwd = passwd
public typealias Group = group

public extension Path {
    /// The home directory for the calling process's user
    var home: DirectoryPath? {
        return try? getHome()
    }

    /// The home directory for the calling process's user
    static var home: DirectoryPath? {
        return try? getHome()
    }
}

/**
 Returns the home directory for a specified user

 - Parameter username: The username of the user whose home directory you wish to retrieve
 - Returns: The home directory of the specified user

 - Throws: `UserInfoError.userDoesNotExist` when there was no user found with the specified username
 - Throws: `UserInfoError.interruptedBySignal` when the API call was interrupted by a signal handler
 - Throws: `UserInfoError.ioError` when an I/O error occurred during the API call
 - Throws: `UserInfoError.noMoreProcessFileDescriptors` when the process has no more available file descriptors
 - Throws: `UserInfoError.noMoreSystemFileDescriptors` when the system has no more available file descriptors
 - Throws: `UserInfoError.outOfMemory` when there is insufficient memory to allocate the underlying C passwd struct
 */
public func getHome(username: String) throws -> DirectoryPath {
    let info = try getUserInfo(username: username)
    return try DirectoryPath(String(cString: info.pw_dir)) ?! UserInfoError.invalidHomeDirectory
}

/**
 Returns the home directory for a specified user

 - Parameter uid: The uid of the user whose home directory you wish to retrieve
 - Returns: The home directory of the specified user

 - Throws: `UserInfoError.userDoesNotExist` when there was no user found with the specified uid
 - Throws: `UserInfoError.interruptedBySignal` when the API call was interrupted by a signal handler
 - Throws: `UserInfoError.ioError` when an I/O error occurred during the API call
 - Throws: `UserInfoError.noMoreProcessFileDescriptors` when the process has no more available file descriptors
 - Throws: `UserInfoError.noMoreSystemFileDescriptors` when the system has no more available file descriptors
 - Throws: `UserInfoError.outOfMemory` when there is insufficient memory to allocate the underlying C passwd struct
 */
public func getHome(uid: UID = geteuid()) throws -> DirectoryPath {
    let info = try getUserInfo(uid: uid)
    return try DirectoryPath(String(cString: info.pw_dir)) ?! UserInfoError.invalidHomeDirectory
}

/**
 Returns information about the user requested

 - Parameter username: The username of the user whose information you wish to retrieve
 - Returns: A Passwd struct containing information about the user. (see getpwnam(3))

 - Throws: `UserInfoError.userDoesNotExist` when there was no user found with the specified username
 - Throws: `UserInfoError.interruptedBySignal` when the API call was interrupted by a signal handler
 - Throws: `UserInfoError.ioError` when an I/O error occurred during the API call
 - Throws: `UserInfoError.noMoreProcessFileDescriptors` when the process has no more available file descriptors
 - Throws: `UserInfoError.noMoreSystemFileDescriptors` when the system has no more available file descriptors
 - Throws: `UserInfoError.outOfMemory` when there is insufficient memory to allocate the underlying C passwd struct
 */
func getUserInfo(username: String) throws -> Passwd {
    // getpwnam(2) documentation says "If one wants to check errno after
    // the call, it should be set to zero before the call."
    errno = 0
    return try getpwnam(username)?.pointee ?! UserInfoError.getError()
}

/**
 Returns information about the user requested

 - Parameter uid: The uid of the user whose information you wish to retrieve
 - Returns: A Passwd struct containing information about the user. (see getpwuid(3))

 - Throws: `UserInfoError.userDoesNotExist` when there was no user found with the specified uid
 - Throws: `UserInfoError.interruptedBySignal` when the API call was interrupted by a signal handler
 - Throws: `UserInfoError.ioError` when an I/O error occurred during the API call
 - Throws: `UserInfoError.noMoreProcessFileDescriptors` when the process has no more available file descriptors
 - Throws: `UserInfoError.noMoreSystemFileDescriptors` when the system has no more available file descriptors
 - Throws: `UserInfoError.outOfMemory` when there is insufficient memory to allocate the underlying C passwd struct
 */
func getUserInfo(uid: UID) throws -> Passwd {
    // getpwuid(2) documentation says "If one wants to check errno after
    // the call, it should be set to zero before the call."
    errno = 0
    return try getpwuid(uid)?.pointee ?! UserInfoError.getError()
}

/**
 Returns information about the group requested

 - Parameter groupname: The name of the group whose information you wish to retrieve
 - Returns: A Group struct containing information about the group. (see getgrnam(3))

 - Throws: `GroupInfoError.groupDoesNotExist` when there was no group found with the specified group name
 - Throws: `GroupInfoError.interruptedBySignal` when the API call was interrupted by a signal handler
 - Throws: `GroupInfoError.ioError` when an I/O error occurred during the API call
 - Throws: `GroupInfoError.noMoreProcessFileDescriptors` when the process has no more available file descriptors
 - Throws: `GroupInfoError.noMoreSystemFileDescriptors` when the system has no more available file descriptors
 - Throws: `GroupInfoError.outOfMemory` when there is insufficient memory to allocate the underlying C group struct
 */
func getGroupInfo(groupname: String) throws -> Group {
    // getgrnam(2) documentation says "If one wants to check errno after
    // the call, it should be set to zero before the call."
    errno = 0
    return try getgrnam(groupname)?.pointee ?! GroupInfoError.getError()
}

/**
 Returns information about the group requested

 - Parameter gid: The gid of the group whose information you wish to retrieve
 - Returns: A Group struct containing information about the group. (see getgrgid(3))

 - Throws: `GroupInfoError.groupDoesNotExist` when there was no group found with the specified gid
 - Throws: `GroupInfoError.interruptedBySignal` when the API call was interrupted by a signal handler
 - Throws: `GroupInfoError.ioError` when an I/O error occurred during the API call
 - Throws: `GroupInfoError.noMoreProcessFileDescriptors` when the process has no more available file descriptors
 - Throws: `GroupInfoError.noMoreSystemFileDescriptors` when the system has no more available file descriptors
 - Throws: `GroupInfoError.outOfMemory` when there is insufficient memory to allocate the underlying C group struct
 */
func getGroupInfo(gid: GID) throws -> Group {
    // getgrgid(2) documentation says "If one wants to check errno after
    // the call, it should be set to zero before the call."
    errno = 0
    return try getgrgid(gid)?.pointee ?! GroupInfoError.getError()
}
