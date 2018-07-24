#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Path {
    /// The home directory for the calling process's user
    public var home: DirectoryPath? {
        return try? getHome()
    }
    /// The home directory for the calling process's user
    public static var home: DirectoryPath? {
        return try? getHome()
    }
}

/**
Returns the home directory for a specified user

- Parameter username: The username of the user who's home directory you wish to retrieve
- Throws:
    - UserInfoError.userDoesNotExist
    - UserInforError.interrupterdBySignal
    - UserInforError.ioError
    - UserInforError.noMoreProcessFileDescriptors
    - UserInforError.noMoreSystemFileDescriptors
    - UserInforError.outOfMemory
*/
func getHome(_ username: String) throws -> DirectoryPath {
    guard let info = getUserInfo(username) else { throw UserInfoError.getError() }
    guard let dir = DirectoryPath(String(cString: info.pw_dir)) else {
        throw UserInfoError.invalidHomeDirectory
    }
    return dir
}
/**
Returns the home directory for a specified user

- Parameter uid: The uid of the user who's home directory you wish to retrieve
- Throws:
    - UserInfoError.userDoesNotExist
    - UserInforError.interrupterdBySignal
    - UserInforError.ioError
    - UserInforError.noMoreProcessFileDescriptors
    - UserInforError.noMoreSystemFileDescriptors
    - UserInforError.outOfMemory
*/
func getHome(_ uid: uid_t = geteuid()) throws -> DirectoryPath {
    guard let info = getUserInfo(uid) else { throw UserInfoError.getError() }
    guard let dir = DirectoryPath(String(cString: info.pw_dir)) else {
        throw UserInfoError.invalidHomeDirectory
    }
    return dir
}
/// Returns a passwd structure for the specified username
func getUserInfo(_ username: String) -> passwd? {
    // getpwnam(2) documentation says "If one wants to check errno after
    // the call, it should be set to zero before the call."
    errno = 0
    return getpwnam(username)?.pointee
}
func getUserInfo(_ uid: uid_t) -> passwd? {
    // getpwuid(2) documentation says "If one wants to check errno after
    // the call, it should be set to zero before the call."
    errno = 0
    return getpwuid(uid)?.pointee
}

// Returns a group structure for the specified groupname
func getGroupInfo(_ groupname: String) -> group? {
    // getgrnam(2) documentation says "If one wants to check errno after
    // the call, it should be set to zero before the call."
    errno = 0
    return getgrnam(groupname)?.pointee
}
func getGroupInfo(_ gid: gid_t) -> group? {
    // getgrgid(2) documentation says "If one wants to check errno after
    // the call, it should be set to zero before the call."
    errno = 0
    return getgrgid(gid)?.pointee
}
