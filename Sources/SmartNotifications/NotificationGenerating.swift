public protocol NotificationGenerating: Sendable {
    func generateNotification(for request: SmartNotificationRequest) async throws -> NotificationDraft
}
