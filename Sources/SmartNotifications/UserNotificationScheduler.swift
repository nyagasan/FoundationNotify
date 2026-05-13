import Foundation

#if canImport(UserNotifications)
import UserNotifications

public struct UserNotificationScheduler: NotificationScheduling {
    private let center: UNUserNotificationCenter

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    public func schedule(_ draft: NotificationDraft, trigger: NotificationTrigger) async throws -> String {
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(
            identifier: identifier,
            content: makeContent(from: draft),
            trigger: try makeTrigger(from: trigger)
        )

        do {
            try await center.add(request)
            return identifier
        } catch {
            throw SmartNotificationError.schedulingFailed(String(describing: error))
        }
    }

    private func makeContent(from draft: NotificationDraft) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = draft.title
        content.body = draft.body
        if let subtitle = draft.subtitle {
            content.subtitle = subtitle
        }
        if let categoryIdentifier = draft.categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        if let threadIdentifier = draft.threadIdentifier {
            content.threadIdentifier = threadIdentifier
        }
        content.userInfo = draft.userInfo
        return content
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
#else
public struct UserNotificationScheduler: NotificationScheduling {
    public init() {}

    public func schedule(_ draft: NotificationDraft, trigger: NotificationTrigger) async throws -> String {
        throw SmartNotificationError.unsupportedPlatform
    }
}
#endif
