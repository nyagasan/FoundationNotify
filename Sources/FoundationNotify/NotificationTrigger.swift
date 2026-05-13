import Foundation

public enum NotificationTrigger: Sendable, Codable, Equatable {
    case timeInterval(TimeInterval, repeats: Bool)
    case date(Date)
    case calendar(DateComponents, repeats: Bool)

    public static func after(_ interval: NotificationTimeInterval) -> NotificationTrigger {
        .timeInterval(interval.timeInterval, repeats: false)
    }
}

public struct NotificationTimeInterval: Sendable, Codable, Equatable, Comparable {
    public var timeInterval: TimeInterval

    public init(_ timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    public static func seconds(_ value: TimeInterval) -> NotificationTimeInterval {
        NotificationTimeInterval(value)
    }

    public static func minutes(_ value: TimeInterval) -> NotificationTimeInterval {
        NotificationTimeInterval(value * 60)
    }

    public static func hours(_ value: TimeInterval) -> NotificationTimeInterval {
        NotificationTimeInterval(value * 60 * 60)
    }

    public static func < (lhs: NotificationTimeInterval, rhs: NotificationTimeInterval) -> Bool {
        lhs.timeInterval < rhs.timeInterval
    }
}

public enum NotificationSchedule: Sendable, Codable, Equatable {
    case daily(hour: Int, minute: Int)
    case weekly(weekday: Int, hour: Int, minute: Int)
    case monthly(day: Int, hour: Int, minute: Int)
    case components(DateComponents)

    public var trigger: NotificationTrigger {
        switch self {
        case let .daily(hour, minute):
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            return .calendar(components, repeats: true)
        case let .weekly(weekday, hour, minute):
            var components = DateComponents()
            components.weekday = weekday
            components.hour = hour
            components.minute = minute
            return .calendar(components, repeats: true)
        case let .monthly(day, hour, minute):
            var components = DateComponents()
            components.day = day
            components.hour = hour
            components.minute = minute
            return .calendar(components, repeats: true)
        case let .components(components):
            return .calendar(components, repeats: true)
        }
    }
}
