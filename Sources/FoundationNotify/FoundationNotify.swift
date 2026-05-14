import Foundation

/// A convenience namespace for generating, validating, authorizing, and scheduling local notifications.
public enum FoundationNotify {
    public nonisolated(unsafe) static var client: Client = .init(
        generator: FoundationModelsNotificationGenerator(),
        scheduler: UserNotificationScheduler(),
        authorizer: UserNotificationAuthorizationClient()
    )

    public static func generate(
        context: String,
        tone: NotificationTone,
        intent: NotificationIntent,
        locale: Locale? = .current,
        constraints: NotificationConstraints = .default
    ) async throws -> NotificationDraft {
        try await client.generate(
            context: context,
            tone: tone,
            intent: intent,
            locale: locale,
            constraints: constraints
        )
    }

    public static func generate(_ request: Request) async throws -> NotificationDraft {
        try await client.generate(request)
    }

    @discardableResult
    public static func schedule(_ draft: NotificationDraft, trigger: NotificationTrigger) async throws -> String {
        try await client.schedule(draft, trigger: trigger)
    }

    @discardableResult
    public static func schedule(
        _ draft: NotificationDraft,
        trigger: NotificationTrigger,
        constraints: NotificationConstraints
    ) async throws -> String {
        try await client.schedule(draft, trigger: trigger, constraints: constraints)
    }

    @discardableResult
    public static func schedule(_ draft: NotificationDraft, after interval: NotificationTimeInterval) async throws -> String {
        try await client.schedule(draft, after: interval)
    }

    @discardableResult
    public static func schedule(_ draft: NotificationDraft, at date: Date) async throws -> String {
        try await client.schedule(draft, at: date)
    }

    @discardableResult
    public static func schedule(_ draft: NotificationDraft, components: DateComponents, repeats: Bool = false) async throws -> String {
        try await client.schedule(draft, components: components, repeats: repeats)
    }

    @discardableResult
    public static func schedule(_ draft: NotificationDraft, repeating schedule: NotificationSchedule) async throws -> String {
        try await client.schedule(draft, repeating: schedule)
    }

    @discardableResult
    public static func schedule(
        after interval: NotificationTimeInterval,
        context: String,
        tone: NotificationTone,
        intent: NotificationIntent,
        locale: Locale? = .current,
        constraints: NotificationConstraints = .default
    ) async throws -> String {
        try await client.schedule(
            after: interval,
            context: context,
            tone: tone,
            intent: intent,
            locale: locale,
            constraints: constraints
        )
    }

    @discardableResult
    public static func schedule(
        at date: Date,
        context: String,
        tone: NotificationTone,
        intent: NotificationIntent,
        locale: Locale? = .current,
        constraints: NotificationConstraints = .default
    ) async throws -> String {
        try await client.schedule(
            at: date,
            context: context,
            tone: tone,
            intent: intent,
            locale: locale,
            constraints: constraints
        )
    }

    @discardableResult
    public static func schedule(
        repeating schedule: NotificationSchedule,
        context: String,
        tone: NotificationTone,
        intent: NotificationIntent,
        locale: Locale? = .current,
        constraints: NotificationConstraints = .default
    ) async throws -> String {
        try await client.schedule(
            repeating: schedule,
            context: context,
            tone: tone,
            intent: intent,
            locale: locale,
            constraints: constraints
        )
    }

    public static func requestAuthorization(options: NotificationAuthorizationOptions = .default) async throws -> Bool {
        try await client.requestAuthorization(options: options)
    }

    public static func authorizationStatus() async -> NotificationAuthorizationStatus {
        await client.authorizationStatus()
    }
}
