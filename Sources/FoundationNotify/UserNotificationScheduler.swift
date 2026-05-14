import Foundation

#if canImport(UserNotifications)
@preconcurrency import UserNotifications

/// Schedules local notifications through `UNUserNotificationCenter`.
public actor UserNotificationScheduler: NotificationScheduling {
    private let center: UNUserNotificationCenter

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    public func schedule(_ draft: NotificationDraft, trigger: NotificationTrigger) async throws -> String {
        let identifier = UUID().uuidString

        do {
            let categoryIdentifier = try await registerCategoryIfNeeded(for: draft)
            let request = UNNotificationRequest(
                identifier: identifier,
                content: makeContent(from: draft, categoryIdentifier: categoryIdentifier),
                trigger: try makeTrigger(from: trigger)
            )
            try await center.add(request)
            return identifier
        } catch {
            throw FoundationNotify.Error.schedulingFailed(String(describing: error))
        }
    }

    private func makeContent(from draft: NotificationDraft, categoryIdentifier: String?) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = draft.title
        content.body = draft.body
        if let subtitle = draft.subtitle {
            content.subtitle = subtitle
        }
        if let categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        if let threadIdentifier = draft.threadIdentifier {
            content.threadIdentifier = threadIdentifier
        }
        content.userInfo = draft.userInfo
        return content
    }

    private func registerCategoryIfNeeded(for draft: NotificationDraft) async throws -> String? {
        guard !draft.actions.isEmpty else {
            return draft.categoryIdentifier
        }

        let categoryIdentifier = draft.categoryIdentifier ?? "foundation-notify-\(UUID().uuidString)"
        let actions = draft.actions.map { action in
            UNNotificationAction(
                identifier: action.identifier,
                title: action.title,
                options: action.options.userNotificationActionOptions
            )
        }
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: actions,
            intentIdentifiers: [],
            options: []
        )

        let existingCategories = await center.notificationCategories()
        var categories = Set(existingCategories.filter { $0.identifier != categoryIdentifier })
        categories.insert(category)
        center.setNotificationCategories(categories)
        return categoryIdentifier
    }

    private func makeTrigger(from trigger: NotificationTrigger) throws -> UNNotificationTrigger {
        switch trigger {
        case let .timeInterval(interval, repeats):
            return UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats)
        case let .date(date):
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: date
            )
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        case let .calendar(components, repeats):
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        }
    }
}

private extension NotificationActionDraft.Options {
    var userNotificationActionOptions: UNNotificationActionOptions {
        var options: UNNotificationActionOptions = []
        if contains(.foreground) {
            options.insert(.foreground)
        }
        if contains(.destructive) {
            options.insert(.destructive)
        }
        if contains(.authenticationRequired) {
            options.insert(.authenticationRequired)
        }
        return options
    }
}
#else
/// A placeholder scheduler for platforms where UserNotifications cannot be imported.
public actor UserNotificationScheduler: NotificationScheduling {
    public init() {}

    public func schedule(_ draft: NotificationDraft, trigger: NotificationTrigger) async throws -> String {
        throw FoundationNotify.Error.unsupportedPlatform
    }
}
#endif
