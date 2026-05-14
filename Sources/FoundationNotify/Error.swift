public extension FoundationNotify {
    /// Errors surfaced by generation, validation, authorization, and scheduling operations.
    enum Error: Swift.Error, Sendable, Equatable {
        case generationFailed(String)
        case validationFailed([NotificationValidationIssue])
        case authorizationDenied
        case schedulingFailed(String)
        case invalidSchedule(String)
        case unsupportedPlatform
    }
}

public enum NotificationValidationIssue: Sendable, Codable, Equatable {
    case emptyTitle
    case emptyBody
    case titleTooLong(max: Int, actual: Int)
    case bodyTooLong(max: Int, actual: Int)
    case tooManyActions(max: Int, actual: Int)
    case emptyActionIdentifier(index: Int)
    case duplicateActionIdentifier(String)
    case actionTitleTooLong(identifier: String, max: Int, actual: Int)
    case containsForbiddenPhrase(String)
}
