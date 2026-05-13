import XCTest
@testable import FoundationNotify

final class FallbackNotificationGeneratorTests: XCTestCase {
    func testFallbackGeneratorCreatesJapaneseActionableDraft() async throws {
        let request = FoundationNotify.Request(
            context: "ユーザーは英単語学習中。復習を促したい。",
            tone: .friendly,
            intent: .reminder,
            locale: "ja_JP"
        )

        let draft = try await FallbackNotificationGenerator().generateNotification(for: request)

        XCTAssertFalse(draft.title.isEmpty)
        XCTAssertTrue(draft.body.contains("復習"))
        XCTAssertEqual(draft.categoryIdentifier, "reminder")
        XCTAssertEqual(draft.userInfo["source"], "FoundationNotify")
        XCTAssertEqual(
            draft.actions,
            [
                NotificationActionDraft(identifier: "REVIEW_NOW", title: "今すぐ確認"),
                NotificationActionDraft(identifier: "LATER", title: "あとで")
            ]
        )
    }

    func testFallbackGeneratorRespectsLengthConstraints() async throws {
        let request = FoundationNotify.Request(
            context: "Review your vocabulary flashcards now.",
            tone: .professional,
            intent: .learning,
            locale: "en_US",
            constraints: NotificationConstraints(maxTitleLength: 8, maxBodyLength: 12, requireActionableCopy: false)
        )

        let draft = try await FallbackNotificationGenerator().generateNotification(for: request)

        XCTAssertLessThanOrEqual(draft.title.count, 8)
        XCTAssertLessThanOrEqual(draft.body.count, 12)
    }

    func testFallbackGeneratorRespectsActionConstraints() async throws {
        let request = FoundationNotify.Request(
            context: "Review your vocabulary flashcards now.",
            tone: .professional,
            intent: .reminder,
            locale: "en_US",
            constraints: NotificationConstraints(maxActionCount: 1, maxActionTitleLength: 6)
        )

        let draft = try await FallbackNotificationGenerator().generateNotification(for: request)

        XCTAssertEqual(draft.actions, [
            NotificationActionDraft(identifier: "REVIEW_NOW", title: "Review")
        ])
    }
}
