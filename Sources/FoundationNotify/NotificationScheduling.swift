/// Schedules a notification draft with the underlying notification system.
public protocol NotificationScheduling: Sendable {
    func schedule(_ draft: NotificationDraft, trigger: NotificationTrigger) async throws -> String
}
