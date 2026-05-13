public protocol NotificationScheduling: Sendable {
    func schedule(_ draft: NotificationDraft, trigger: NotificationTrigger) async throws -> String
}
