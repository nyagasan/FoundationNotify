import Testing
@testable import FoundationNotify

struct FallbackNotificationGeneratorTests {
    @Test func fallbackGeneratorCreatesJapaneseActionableDraft() async throws {
        let request = FoundationNotify.Request(
            context: "ユーザーは英単語学習中。復習を促したい。",
            tone: .friendly,
            intent: .reminder,
            locale: "ja_JP"
        )

        let draft = try await FallbackNotificationGenerator().generateNotification(for: request)

        #expect(!draft.title.isEmpty)
        #expect(draft.body.contains("復習"))
        #expect(draft.categoryIdentifier == "reminder")
        #expect(draft.userInfo["source"] == "FoundationNotify")
        #expect(
            draft.actions == [
                NotificationActionDraft(identifier: "REVIEW_NOW", title: "今すぐ確認"),
                NotificationActionDraft(identifier: "LATER", title: "あとで")
            ]
        )
    }

    @Test(arguments: [
        GeneratedDraftLength.title(max: 8),
        .body(max: 12)
    ])
    func fallbackGeneratorRespectsLengthConstraints(_ length: GeneratedDraftLength) async throws {
        let request = FoundationNotify.Request(
            context: "Review your vocabulary flashcards now.",
            tone: .professional,
            intent: .learning,
            locale: "en_US",
            constraints: NotificationConstraints(maxTitleLength: 8, maxBodyLength: 12)
        )

        let draft = try await FallbackNotificationGenerator().generateNotification(for: request)

        switch length {
        case let .title(max):
            #expect(draft.title.count <= max)
        case let .body(max):
            #expect(draft.body.count <= max)
        }
    }

    @Test func fallbackGeneratorRespectsActionConstraints() async throws {
        let request = FoundationNotify.Request(
            context: "Review your vocabulary flashcards now.",
            tone: .professional,
            intent: .reminder,
            locale: "en_US",
            constraints: NotificationConstraints(maxActionCount: 1, maxActionTitleLength: 6)
        )

        let draft = try await FallbackNotificationGenerator().generateNotification(for: request)

        #expect(draft.actions == [
            NotificationActionDraft(identifier: "REVIEW_NOW", title: "Review")
        ])
    }

    enum GeneratedDraftLength: Sendable {
        case title(max: Int)
        case body(max: Int)
    }
}
