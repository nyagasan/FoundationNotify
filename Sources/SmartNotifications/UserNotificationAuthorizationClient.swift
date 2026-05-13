#if canImport(UserNotifications)
@preconcurrency import UserNotifications

public struct UserNotificationAuthorizationClient: NotificationAuthorizing, @unchecked Sendable {
    private let center: UNUserNotificationCenter

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    public func requestAuthorization(options: NotificationAuthorizationOptions = .default) async throws -> Bool {
        do {
            return try await center.requestAuthorization(options: options.userNotificationOptions)
        } catch {
            throw SmartNotificationError.schedulingFailed(String(describing: error))
        }
    }

    public func authorizationStatus() async -> NotificationAuthorizationStatus {
        let settings = await center.notificationSettings()
        return NotificationAuthorizationStatus(settings.authorizationStatus)
    }
}

private extension NotificationAuthorizationOptions {
    var userNotificationOptions: UNAuthorizationOptions {
        var options: UNAuthorizationOptions = []
        if contains(.alert) {
            options.insert(.alert)
        }
        if contains(.sound) {
            options.insert(.sound)
        }
        if contains(.badge) {
            options.insert(.badge)
        }
        return options
    }
}

private extension NotificationAuthorizationStatus {
    init(_ status: UNAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .denied:
            self = .denied
        case .authorized:
            self = .authorized
        case .provisional:
            self = .provisional
        case .ephemeral:
            self = .ephemeral
        @unknown default:
            self = .unknown
        }
    }
}
#else
public struct UserNotificationAuthorizationClient: NotificationAuthorizing {
    public init() {}

    public func requestAuthorization(options: NotificationAuthorizationOptions = .default) async throws -> Bool {
        throw SmartNotificationError.unsupportedPlatform
    }

    public func authorizationStatus() async -> NotificationAuthorizationStatus {
        .unsupported
    }
}
#endif
