public struct NotificationConstraints: Sendable, Codable, Equatable {
    public var maxTitleLength: Int
    public var maxBodyLength: Int
    public var forbiddenPhrases: [String]
    public var requireActionableCopy: Bool

    public init(
        maxTitleLength: Int = 64,
        maxBodyLength: Int = 180,
        forbiddenPhrases: [String] = [],
        requireActionableCopy: Bool = true
    ) {
        self.maxTitleLength = maxTitleLength
        self.maxBodyLength = maxBodyLength
        self.forbiddenPhrases = forbiddenPhrases
        self.requireActionableCopy = requireActionableCopy
    }

    public static let `default` = NotificationConstraints()
}
