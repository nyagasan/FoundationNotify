import Foundation
import Testing
@testable import FoundationNotify

struct NotificationValidatorTests {
    @Test func validDraftPasses() throws {
        let draft = NotificationDraft(title: "Review time", body: "Review five words now.")
        try NotificationValidator().validate(draft)
    }

    @Test func emptyTitleFails() {
        let draft = NotificationDraft(title: " ", body: "Review five words now.")

        #expect {
            try NotificationValidator().validate(draft)
        } throws: { error in
            error as? FoundationNotify.Error == .validationFailed([.emptyTitle])
        }
    }

    @Test func lengthAndForbiddenPhraseFailuresAreReportedTogether() {
        let draft = NotificationDraft(title: "Too long", body: "Open this spam phrase now.")
        let constraints = NotificationConstraints(
            maxTitleLength: 4,
            maxBodyLength: 10,
            forbiddenPhrases: ["spam phrase"]
        )

        #expect {
            try NotificationValidator().validate(draft, constraints: constraints)
        } throws: { error in
            error as? FoundationNotify.Error == .validationFailed([
                    .titleTooLong(max: 4, actual: 8),
                    .bodyTooLong(max: 10, actual: 26),
                    .containsForbiddenPhrase("spam phrase")
                ])
        }
    }

    @Test func tooManyActionsFails() {
        let draft = NotificationDraft(
            title: "Review time",
            body: "Review five words now.",
            actions: [
                NotificationActionDraft(identifier: "ONE", title: "One"),
                NotificationActionDraft(identifier: "TWO", title: "Two")
            ]
        )
        let constraints = NotificationConstraints(maxActionCount: 1)

        #expect {
            try NotificationValidator().validate(draft, constraints: constraints)
        } throws: { error in
            error as? FoundationNotify.Error == .validationFailed([.tooManyActions(max: 1, actual: 2)])
        }
    }

    @Test func invalidActionIdentifiersFail() {
        let draft = NotificationDraft(
            title: "Review time",
            body: "Review five words now.",
            actions: [
                NotificationActionDraft(identifier: "REVIEW_NOW", title: "Review now"),
                NotificationActionDraft(identifier: " ", title: "Later"),
                NotificationActionDraft(identifier: "REVIEW_NOW", title: "Again")
            ]
        )

        #expect {
            try NotificationValidator().validate(draft)
        } throws: { error in
            error as? FoundationNotify.Error == .validationFailed([
                    .emptyActionIdentifier(index: 1),
                    .duplicateActionIdentifier("REVIEW_NOW")
                ])
        }
    }

    @Test func actionTitleTooLongFails() {
        let draft = NotificationDraft(
            title: "Review time",
            body: "Review five words now.",
            actions: [
                NotificationActionDraft(identifier: "REVIEW_NOW", title: "Review now")
            ]
        )
        let constraints = NotificationConstraints(maxActionTitleLength: 4)

        #expect {
            try NotificationValidator().validate(draft, constraints: constraints)
        } throws: { error in
            error as? FoundationNotify.Error == .validationFailed([
                    .actionTitleTooLong(identifier: "REVIEW_NOW", max: 4, actual: 10)
                ])
        }
    }

    @Test func pastDateTriggerFails() {
        let now = Date(timeIntervalSince1970: 1_000)
        let trigger = NotificationTrigger.date(Date(timeIntervalSince1970: 999))

        #expect {
            try NotificationValidator().validate(trigger, now: now)
        } throws: { error in
            error as? FoundationNotify.Error == .invalidSchedule("Date trigger must be in the future.")
        }
    }

    @Test(arguments: InvalidRepeatingComponentCase.allCases)
    func invalidRepeatingComponentsFail(_ testCase: InvalidRepeatingComponentCase) {
        #expect {
            try NotificationValidator().validate(.calendar(testCase.components, repeats: true))
        } throws: { error in
            error as? FoundationNotify.Error == testCase.expected
        }
    }

    enum InvalidRepeatingComponentCase: CaseIterable, Sendable {
        case hour
        case minute
        case second
        case weekday
        case day
        case empty

        var components: DateComponents {
            switch self {
            case .hour:
                return DateComponents(hour: 24)
            case .minute:
                return DateComponents(minute: 60)
            case .second:
                return DateComponents(second: 60)
            case .weekday:
                return DateComponents(weekday: 8)
            case .day:
                return DateComponents(day: 32)
            case .empty:
                return DateComponents()
            }
        }

        var expected: FoundationNotify.Error {
            switch self {
            case .hour:
                return .invalidSchedule("Calendar hour must be between 0 and 23.")
            case .minute:
                return .invalidSchedule("Calendar minute must be between 0 and 59.")
            case .second:
                return .invalidSchedule("Calendar second must be between 0 and 59.")
            case .weekday:
                return .invalidSchedule("Calendar weekday must be between 1 and 7.")
            case .day:
                return .invalidSchedule("Calendar day must be between 1 and 31.")
            case .empty:
                return .invalidSchedule("Repeating calendar triggers need at least one date component.")
            }
        }
    }
}
