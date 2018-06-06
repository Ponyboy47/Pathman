#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Path {
    /// The home directory for the calling process's user
    public var homeDirectory: DirectoryPath? {
        return try? Self.getHomeDirectory()
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
    public func getHomeDirectory(_ username: String) throws -> DirectoryPath {
        return try Self.getHomeDirectory(username)
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
    public static func getHomeDirectory(_ username: String) throws -> DirectoryPath {
        guard let info = getUserInfo(username) else { throw UserInfoError.getError() }
        return DirectoryPath(String(cString: info.pw_dir))!
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
    public func getHomeDirectory(_ uid: uid_t = geteuid()) throws -> DirectoryPath {
        return try Self.getHomeDirectory(uid)
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
    public static func getHomeDirectory(_ uid: uid_t = geteuid()) throws -> DirectoryPath {
        guard let info = getUserInfo(uid) else { throw UserInfoError.getError() }
        return DirectoryPath(String(cString: info.pw_dir))!
    }
    /// Returns a passwd structure for the specified username
    static func getUserInfo(_ username: String) -> passwd? {
        return getpwnam(username)?.pointee
    }
    static func getUserInfo(_ uid: uid_t) -> passwd? {
        return getpwuid(uid)?.pointee
    }
}
