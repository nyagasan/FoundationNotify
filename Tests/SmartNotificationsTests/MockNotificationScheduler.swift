import Foundation
@testable import SmartNotifications

actor MockNotificationScheduler: NotificationScheduling {
    private(set) var scheduled: [(draft: NotificationDraft, trigger: NotificationTrigger)] = []
    var identifier = "mock-notification-id"

    func schedule(_ draft: NotificationDraft, trigger: NotificationTrigger) async throws -> String {
        scheduled.append((draft, trigger))
        return identifier
    }
}

struct MockNotificationGenerator: NotificationGenerating {
    var draft: NotificationDraft

    func generateNotification(for request: SmartNotificationRequest) async throws -> NotificationDraft {
        draft
    }
}

struct MockNotificationAuthorizer: NotificationAuthorizing {
    var granted = true
    var status: NotificationAuthorizationStatus = .authorized

    func requestAuthorization(options: NotificationAuthorizationOptions) async throws -> Bool {
        granted
    }

    func authorizationStatus() async -> NotificationAuthorizationStatus {
        status
    }
}
