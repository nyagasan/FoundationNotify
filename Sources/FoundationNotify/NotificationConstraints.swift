/// Length, content, and action limits used to validate generated notification drafts.
public struct NotificationConstraints: Sendable, Codable, Equatable {
    public var maxTitleLength: Int
    public var maxBodyLength: Int
    public var maxActionCount: Int
    public var maxActionTitleLength: Int
    public var forbiddenPhrases: [String]
    public var requireActionableCopy: Bool

    private enum CodingKeys: String, CodingKey {
        case maxTitleLength
        case maxBodyLength
        case maxActionCount
        case maxActionTitleLength
        case forbiddenPhrases
        case requireActionableCopy
    }

    public init(
        maxTitleLength: Int = 64,
        maxBodyLength: Int = 180,
        maxActionCount: Int = 3,
        maxActionTitleLength: Int = 24,
        forbiddenPhrases: [String] = [],
        requireActionableCopy: Bool = true
    ) {
        self.maxTitleLength = maxTitleLength
        self.maxBodyLength = maxBodyLength
        self.maxActionCount = maxActionCount
        self.maxActionTitleLength = maxActionTitleLength
        self.forbiddenPhrases = forbiddenPhrases
        self.requireActionableCopy = requireActionableCopy
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        maxTitleLength = try container.decodeIfPresent(Int.self, forKey: .maxTitleLength) ?? 64
        maxBodyLength = try container.decodeIfPresent(Int.self, forKey: .maxBodyLength) ?? 180
        maxActionCount = try container.decodeIfPresent(Int.self, forKey: .maxActionCount) ?? 3
        maxActionTitleLength = try container.decodeIfPresent(Int.self, forKey: .maxActionTitleLength) ?? 24
        forbiddenPhrases = try container.decodeIfPresent([String].self, forKey: .forbiddenPhrases) ?? []
        requireActionableCopy = try container.decodeIfPresent(Bool.self, forKey: .requireActionableCopy) ?? true
    }

    public static let `default` = NotificationConstraints()
}
