public struct SmartNotificationRequest: Sendable, Codable, Equatable {
    public var context: String
    public var tone: NotificationTone
    public var intent: NotificationIntent
    public var locale: LocaleIdentifier?
    public var constraints: NotificationConstraints

    public init(
        context: String,
        tone: NotificationTone,
        intent: NotificationIntent,
        locale: LocaleIdentifier? = .current,
        constraints: NotificationConstraints = .default
    ) {
        self.context = context
        self.tone = tone
        self.intent = intent
        self.locale = locale
        self.constraints = constraints
    }
}
