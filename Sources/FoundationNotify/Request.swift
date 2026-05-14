import Foundation

public extension FoundationNotify {
    /// Input context and policy for generating a notification draft.
    struct Request: Sendable, Codable, Equatable {
        public var context: String
        public var tone: NotificationTone
        public var intent: NotificationIntent
        public var locale: Locale?
        public var constraints: NotificationConstraints

        public init(
            context: String,
            tone: NotificationTone,
            intent: NotificationIntent,
            locale: Locale? = .current,
            constraints: NotificationConstraints = .default
        ) {
            self.context = context
            self.tone = tone
            self.intent = intent
            self.locale = locale
            self.constraints = constraints
        }
    }
}
