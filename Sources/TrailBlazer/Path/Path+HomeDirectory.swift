#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Path {
    /// The home directory for the calling process's user
    public var home: DirectoryPath? {
        return try? Self.getHome()
    }
    /// The home directory for the calling process's user
    public static var home: DirectoryPath? {
        return try? Self.getHome()
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
    public func getHome(_ username: String) throws -> DirectoryPath {
        return try Self.getHome(username)
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
    public static func getHome(_ username: String) throws -> DirectoryPath {
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
    public func getHome(_ uid: uid_t = geteuid()) throws -> DirectoryPath {
        return try Self.getHome(uid)
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
    public static func getHome(_ uid: uid_t = geteuid()) throws -> DirectoryPath {
        guard let info = getUserInfo(uid) else { throw UserInfoError.getError() }
        guard let dir = DirectoryPath(String(cString: info.pw_dir)) else {
            throw UserInfoError.invalidHomeDirectory
        }
        return dir
    }
    /// Returns a passwd structure for the specified username
    static func getUserInfo(_ username: String) -> passwd? {
        return getpwnam(username)?.pointee
    }
    static func getUserInfo(_ uid: uid_t) -> passwd? {
        return getpwuid(uid)?.pointee
    }

    // Returns a group structure for the specified groupname
    static func getGroupInfo(_ groupname: String) -> group? {
        return getgrnam(groupname)?.pointee
    }
    static func getGroupInfo(_ gid: gid_t) -> group? {
        return getgrgid(gid)?.pointee
    }
}
