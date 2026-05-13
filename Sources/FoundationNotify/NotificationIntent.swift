/// The product intent that guides generated notification copy and fallback actions.
public enum NotificationIntent: String, Sendable, Codable, CaseIterable {
    case reminder
    case habit
    case learning
    case wellness
    case productivity
    case event
}
