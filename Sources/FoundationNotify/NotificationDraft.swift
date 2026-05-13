public struct NotificationDraft: Sendable, Codable, Equatable {
    public var title: String
    public var body: String
    public var subtitle: String?
    public var categoryIdentifier: String?
    public var threadIdentifier: String?
    public var userInfo: [String: String]

    public init(
        title: String,
        body: String,
        subtitle: String? = nil,
        categoryIdentifier: String? = nil,
        threadIdentifier: String? = nil,
        userInfo: [String: String] = [:]
    ) {
        self.title = title
        self.body = body
        self.subtitle = subtitle
        self.categoryIdentifier = categoryIdentifier
        self.threadIdentifier = threadIdentifier
        self.userInfo = userInfo
    }
}
