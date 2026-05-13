import Foundation
import XCTest
@testable import FoundationNotify

final class NotificationValidatorTests: XCTestCase {
    func testValidDraftPasses() throws {
        let draft = NotificationDraft(title: "Review time", body: "Review five words now.")
        XCTAssertNoThrow(try NotificationValidator().validate(draft))
    }

    func testEmptyTitleFails() {
        let draft = NotificationDraft(title: " ", body: "Review five words now.")

        XCTAssertThrowsError(try NotificationValidator().validate(draft)) { error in
            XCTAssertEqual(error as? FoundationNotify.Error, .validationFailed([.emptyTitle]))
        }
    }

    func testLengthAndForbiddenPhraseFailuresAreReportedTogether() {
        let draft = NotificationDraft(title: "Too long", body: "Open this spam phrase now.")
        let constraints = NotificationConstraints(
            maxTitleLength: 4,
            maxBodyLength: 10,
            forbiddenPhrases: ["spam phrase"],
            requireActionableCopy: true
        )

        XCTAssertThrowsError(try NotificationValidator().validate(draft, constraints: constraints)) { error in
            XCTAssertEqual(
                error as? FoundationNotify.Error,
                .validationFailed([
                    .titleTooLong(max: 4, actual: 8),
                    .bodyTooLong(max: 10, actual: 26),
                    .containsForbiddenPhrase("spam phrase")
                ])
            )
        }
    }

    func testMissingActionableCopyFailsWhenRequired() {
        let draft = NotificationDraft(title: "Quiet note", body: "A short neutral sentence.")

        XCTAssertThrowsError(try NotificationValidator().validate(draft)) { error in
            XCTAssertEqual(error as? FoundationNotify.Error, .validationFailed([.missingActionableCopy]))
        }
    }

    func testTooManyActionsFails() {
        let draft = NotificationDraft(
            title: "Review time",
            body: "Review five words now.",
            actions: [
                NotificationActionDraft(identifier: "ONE", title: "One"),
                NotificationActionDraft(identifier: "TWO", title: "Two")
            ]
        )
        let constraints = NotificationConstraints(maxActionCount: 1)

        XCTAssertThrowsError(try NotificationValidator().validate(draft, constraints: constraints)) { error in
            XCTAssertEqual(error as? FoundationNotify.Error, .validationFailed([.tooManyActions(max: 1, actual: 2)]))
        }
    }

    func testInvalidActionIdentifiersFail() {
        let draft = NotificationDraft(
            title: "Review time",
            body: "Review five words now.",
            actions: [
                NotificationActionDraft(identifier: "REVIEW_NOW", title: "Review now"),
                NotificationActionDraft(identifier: " ", title: "Later"),
                NotificationActionDraft(identifier: "REVIEW_NOW", title: "Again")
            ]
        )

        XCTAssertThrowsError(try NotificationValidator().validate(draft)) { error in
            XCTAssertEqual(
                error as? FoundationNotify.Error,
                .validationFailed([
                    .emptyActionIdentifier(index: 1),
                    .duplicateActionIdentifier("REVIEW_NOW")
                ])
            )
        }
    }

    func testActionTitleTooLongFails() {
        let draft = NotificationDraft(
            title: "Review time",
            body: "Review five words now.",
            actions: [
                NotificationActionDraft(identifier: "REVIEW_NOW", title: "Review now")
            ]
        )
        let constraints = NotificationConstraints(maxActionTitleLength: 4)

        XCTAssertThrowsError(try NotificationValidator().validate(draft, constraints: constraints)) { error in
            XCTAssertEqual(
                error as? FoundationNotify.Error,
                .validationFailed([
                    .actionTitleTooLong(identifier: "REVIEW_NOW", max: 4, actual: 10)
                ])
            )
        }
    }

    func testPastDateTriggerFails() {
        let now = Date(timeIntervalSince1970: 1_000)
        let trigger = NotificationTrigger.date(Date(timeIntervalSince1970: 999))

        XCTAssertThrowsError(try NotificationValidator().validate(trigger, now: now)) { error in
            XCTAssertEqual(
                error as? FoundationNotify.Error,
                .invalidSchedule("Date trigger must be in the future.")
            )
        }
    }

    func testInvalidRepeatingComponentsFail() {
        var components = DateComponents()
        components.hour = 24

        XCTAssertThrowsError(try NotificationValidator().validate(.calendar(components, repeats: true))) { error in
            XCTAssertEqual(
                error as? FoundationNotify.Error,
                .invalidSchedule("Calendar hour must be between 0 and 23.")
            )
        }
    }
}
