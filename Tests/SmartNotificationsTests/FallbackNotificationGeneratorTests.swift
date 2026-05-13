import XCTest
@testable import SmartNotifications

final class FallbackNotificationGeneratorTests: XCTestCase {
    func testFallbackGeneratorCreatesJapaneseActionableDraft() async throws {
        let request = SmartNotificationRequest(
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
    }

    func testFallbackGeneratorRespectsLengthConstraints() async throws {
        let request = SmartNotificationRequest(
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
}
