public protocol NotificationAuthorizing: Sendable {
    func requestAuthorization(options: NotificationAuthorizationOptions) async throws -> Bool
    func authorizationStatus() async -> NotificationAuthorizationStatus
}

public struct NotificationAuthorizationOptions: OptionSet, Sendable, Codable, Equatable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let alert = NotificationAuthorizationOptions(rawValue: 1 << 0)
    public static let sound = NotificationAuthorizationOptions(rawValue: 1 << 1)
    public static let badge = NotificationAuthorizationOptions(rawValue: 1 << 2)

    public static let `default`: NotificationAuthorizationOptions = [.alert, .sound, .badge]
}

public enum NotificationAuthorizationStatus: String, Sendable, Codable, Equatable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
    case unknown
    case unsupported
}
