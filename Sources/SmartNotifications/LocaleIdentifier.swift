import Foundation

public struct LocaleIdentifier: RawRepresentable, Sendable, Codable, Equatable, Hashable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

    public static var current: LocaleIdentifier {
        LocaleIdentifier(rawValue: Locale.current.identifier)
    }
}
