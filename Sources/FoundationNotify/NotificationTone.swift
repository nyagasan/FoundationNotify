/// The writing tone requested for generated notification copy.
public enum NotificationTone: String, Sendable, Codable, CaseIterable {
    case friendly
    case gentle
    case energetic
    case professional
    case playful
    case calm
}
