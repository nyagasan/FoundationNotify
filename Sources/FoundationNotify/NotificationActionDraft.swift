/// A structured quick action button that can be attached to a local notification draft.
public struct NotificationActionDraft: Sendable, Codable, Equatable {
    public var identifier: String
    public var title: String
    public var options: Options

    /// Options that control how a notification action is displayed and handled by the system.
    public struct Options: OptionSet, Sendable, Codable, Equatable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let foreground = Options(rawValue: 1 << 0)
        public static let destructive = Options(rawValue: 1 << 1)
        public static let authenticationRequired = Options(rawValue: 1 << 2)
    }

    public init(identifier: String, title: String, options: Options = []) {
        self.identifier = identifier
        self.title = title
        self.options = options
    }
}
