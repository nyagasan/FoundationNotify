import Foundation
import XCTest
@testable import FoundationNotify

final class NotificationActionDraftTests: XCTestCase {
    func testNotificationDraftDecodesWithoutActionsForBackwardCompatibility() throws {
        let data = Data(
            """
            {
              "title": "Review time",
              "body": "Review five words now.",
              "userInfo": {}
            }
            """.utf8
        )

        let draft = try JSONDecoder().decode(NotificationDraft.self, from: data)

        XCTAssertEqual(draft.actions, [])
    }

    func testNotificationConstraintsDecodesActionDefaultsForBackwardCompatibility() throws {
        let data = Data(
            """
            {
              "maxTitleLength": 48,
              "maxBodyLength": 140,
              "forbiddenPhrases": [],
              "requireActionableCopy": true
            }
            """.utf8
        )

        let constraints = try JSONDecoder().decode(NotificationConstraints.self, from: data)

        XCTAssertEqual(constraints.maxActionCount, 3)
        XCTAssertEqual(constraints.maxActionTitleLength, 24)
    }

    func testCodableRoundTripPreservesAction() throws {
        let action = NotificationActionDraft(
            identifier: "REVIEW_NOW",
            title: "Review now",
            options: [.foreground, .authenticationRequired]
        )

        let data = try JSONEncoder().encode(action)
        let decoded = try JSONDecoder().decode(NotificationActionDraft.self, from: data)

        XCTAssertEqual(decoded, action)
    }

    func testOptionsBehaveAsOptionSet() {
        var options: NotificationActionDraft.Options = [.foreground]

        XCTAssertTrue(options.contains(.foreground))
        XCTAssertFalse(options.contains(.destructive))

        options.insert(.destructive)

        XCTAssertTrue(options.contains(.destructive))
        XCTAssertEqual(options.rawValue, 3)
    }
}
