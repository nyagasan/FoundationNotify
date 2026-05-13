public protocol NotificationGenerating: Sendable {
    func generateNotification(for request: FoundationNotify.Request) async throws -> NotificationDraft
}
