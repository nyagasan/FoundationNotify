/// Generates a notification draft from a typed FoundationNotify request.
public protocol NotificationGenerating: Sendable {
    func generateNotification(for request: FoundationNotify.Request) async throws -> NotificationDraft
}
