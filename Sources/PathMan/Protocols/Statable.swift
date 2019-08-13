/// A protocol exposing access to information using the stat(2) utility
public protocol Statable {
    var info: StatInfo { get }
}

public protocol UpdatableStatable: Statable {
    // swiftlint:disable identifier_name
    var _info: StatInfo { get }
    // swiftlint:enable identifier_name
}
