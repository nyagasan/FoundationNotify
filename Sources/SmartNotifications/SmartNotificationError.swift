public enum SmartNotificationError: Error, Sendable, Equatable {
    case generationFailed(String)
    case validationFailed([NotificationValidationIssue])
    case authorizationDenied
    case schedulingFailed(String)
    case invalidSchedule(String)
    case unsupportedPlatform
}

public enum NotificationValidationIssue: Sendable, Codable, Equatable {
    case emptyTitle
    case emptyBody
    case titleTooLong(max: Int, actual: Int)
    case bodyTooLong(max: Int, actual: Int)
    case containsForbiddenPhrase(String)
    case missingActionableCopy
}
