import Foundation

/// Validates notification drafts and triggers before scheduling.
public struct NotificationValidator: Sendable {
    public init() {}

    public func validate(_ draft: NotificationDraft, constraints: NotificationConstraints = .default) throws {
        let issues = validationIssues(for: draft, constraints: constraints)
        guard issues.isEmpty else {
            throw FoundationNotify.Error.validationFailed(issues)
        }
    }

    public func validate(_ trigger: NotificationTrigger, now: Date = Date()) throws {
        switch trigger {
        case let .timeInterval(interval, _):
            guard interval > 0 else {
                throw FoundationNotify.Error.invalidSchedule("Time interval must be greater than zero.")
            }
        case let .date(date):
            guard date > now else {
                throw FoundationNotify.Error.invalidSchedule("Date trigger must be in the future.")
            }
        case let .calendar(components, repeats):
            try validateCalendarComponents(components, repeats: repeats)
        }
    }

    public func validationIssues(
        for draft: NotificationDraft,
        constraints: NotificationConstraints = .default
    ) -> [NotificationValidationIssue] {
        var issues: [NotificationValidationIssue] = []
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = draft.body.trimmingCharacters(in: .whitespacesAndNewlines)

        if title.isEmpty {
            issues.append(.emptyTitle)
        }

        if body.isEmpty {
            issues.append(.emptyBody)
        }

        if draft.title.count > constraints.maxTitleLength {
            issues.append(.titleTooLong(max: constraints.maxTitleLength, actual: draft.title.count))
        }

        if draft.body.count > constraints.maxBodyLength {
            issues.append(.bodyTooLong(max: constraints.maxBodyLength, actual: draft.body.count))
        }

        if draft.actions.count > constraints.maxActionCount {
            issues.append(.tooManyActions(max: constraints.maxActionCount, actual: draft.actions.count))
        }

        var seenActionIdentifiers: Set<String> = []
        for (index, action) in draft.actions.enumerated() {
            let identifier = action.identifier.trimmingCharacters(in: .whitespacesAndNewlines)
            if identifier.isEmpty {
                issues.append(.emptyActionIdentifier(index: index))
            } else if !seenActionIdentifiers.insert(identifier).inserted {
                issues.append(.duplicateActionIdentifier(identifier))
            }

            if action.title.count > constraints.maxActionTitleLength {
                issues.append(
                    .actionTitleTooLong(
                        identifier: action.identifier,
                        max: constraints.maxActionTitleLength,
                        actual: action.title.count
                    )
                )
            }
        }

        let combinedCopy = "\(draft.title)\n\(draft.subtitle ?? "")\n\(draft.body)".localizedLowercase
        for phrase in constraints.forbiddenPhrases where !phrase.isEmpty {
            if combinedCopy.contains(phrase.localizedLowercase) {
                issues.append(.containsForbiddenPhrase(phrase))
            }
        }

        if constraints.requireActionableCopy && !containsActionableCopy(body) {
            issues.append(.missingActionableCopy)
        }

        return issues
    }

    private func containsActionableCopy(_ body: String) -> Bool {
        let markers = [
            "try", "start", "open", "check", "review", "remember", "take", "join", "go", "do",
            "確認", "始め", "開", "復習", "試", "行", "見", "参加", "進め", "しましょう", "しよう"
        ]
        let normalized = body.localizedLowercase
        return markers.contains { normalized.contains($0.localizedLowercase) }
    }

    private func validateCalendarComponents(_ components: DateComponents, repeats: Bool) throws {
        if let hour = components.hour, !(0...23).contains(hour) {
            throw FoundationNotify.Error.invalidSchedule("Calendar hour must be between 0 and 23.")
        }

        if let minute = components.minute, !(0...59).contains(minute) {
            throw FoundationNotify.Error.invalidSchedule("Calendar minute must be between 0 and 59.")
        }

        if let second = components.second, !(0...59).contains(second) {
            throw FoundationNotify.Error.invalidSchedule("Calendar second must be between 0 and 59.")
        }

        if let weekday = components.weekday, !(1...7).contains(weekday) {
            throw FoundationNotify.Error.invalidSchedule("Calendar weekday must be between 1 and 7.")
        }

        if let day = components.day, !(1...31).contains(day) {
            throw FoundationNotify.Error.invalidSchedule("Calendar day must be between 1 and 31.")
        }

        if repeats {
            let hasRepeatComponent = components.hour != nil
                || components.minute != nil
                || components.weekday != nil
                || components.day != nil
            guard hasRepeatComponent else {
                throw FoundationNotify.Error.invalidSchedule("Repeating calendar triggers need at least one date component.")
            }
        }
    }
}
