/// A generated local notification payload and its scheduling metadata.
public struct NotificationDraft: Sendable, Codable, Equatable {
    public var title: String
    public var body: String
    public var subtitle: String?
    public var categoryIdentifier: String?
    public var threadIdentifier: String?
    public var userInfo: [String: String]
    public var actions: [NotificationActionDraft]

    private enum CodingKeys: String, CodingKey {
        case title
        case body
        case subtitle
        case categoryIdentifier
        case threadIdentifier
        case userInfo
        case actions
    }

    public init(
        title: String,
        body: String,
        subtitle: String? = nil,
        categoryIdentifier: String? = nil,
        threadIdentifier: String? = nil,
        userInfo: [String: String] = [:],
        actions: [NotificationActionDraft] = []
    ) {
        self.title = title
        self.body = body
        self.subtitle = subtitle
        self.categoryIdentifier = categoryIdentifier
        self.threadIdentifier = threadIdentifier
        self.userInfo = userInfo
        self.actions = actions
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        categoryIdentifier = try container.decodeIfPresent(String.self, forKey: .categoryIdentifier)
        threadIdentifier = try container.decodeIfPresent(String.self, forKey: .threadIdentifier)
        userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo) ?? [:]
        actions = try container.decodeIfPresent([NotificationActionDraft].self, forKey: .actions) ?? []
    }
}
