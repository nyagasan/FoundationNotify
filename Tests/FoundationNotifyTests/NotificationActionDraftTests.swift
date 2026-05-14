import Foundation
import Testing
@testable import FoundationNotify

struct NotificationActionDraftTests {
    @Test func notificationDraftDecodesWithoutActionsForBackwardCompatibility() throws {
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

        #expect(draft.actions == [])
    }

    @Test func notificationConstraintsDecodesActionDefaultsForBackwardCompatibility() throws {
        let data = Data(
            """
            {
              "maxTitleLength": 48,
              "maxBodyLength": 140,
              "forbiddenPhrases": []
            }
            """.utf8
        )

        let constraints = try JSONDecoder().decode(NotificationConstraints.self, from: data)

        #expect(constraints.maxActionCount == 3)
        #expect(constraints.maxActionTitleLength == 24)
    }

    @Test func codableRoundTripPreservesAction() throws {
        let action = NotificationActionDraft(
            identifier: "REVIEW_NOW",
            title: "Review now",
            options: [.foreground, .authenticationRequired]
        )

        let data = try JSONEncoder().encode(action)
        let decoded = try JSONDecoder().decode(NotificationActionDraft.self, from: data)

        #expect(decoded == action)
    }

    @Test func optionsBehaveAsOptionSet() {
        var options: NotificationActionDraft.Options = [.foreground]

        #expect(options.contains(.foreground))
        #expect(!options.contains(.destructive))

        options.insert(.destructive)

        #expect(options.contains(.destructive))
        #expect(options.rawValue == 3)
    }
}
