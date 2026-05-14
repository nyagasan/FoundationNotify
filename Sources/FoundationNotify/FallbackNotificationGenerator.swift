import Foundation

/// Generates deterministic notification drafts for tests and unsupported Foundation Models environments.
public struct FallbackNotificationGenerator: NotificationGenerating {
    public init() {}

    public func generateNotification(for request: FoundationNotify.Request) async throws -> NotificationDraft {
        let title = title(for: request)
        let body = body(for: request)

        var draft = NotificationDraft(
            title: title,
            body: body,
            categoryIdentifier: request.intent.rawValue,
            threadIdentifier: "smart-notification-\(request.intent.rawValue)",
            userInfo: [
                "source": "FoundationNotify",
                "intent": request.intent.rawValue,
                "tone": request.tone.rawValue
            ],
            actions: actions(for: request)
        )

        draft.title = String(draft.title.prefix(request.constraints.maxTitleLength))
        draft.body = String(draft.body.prefix(request.constraints.maxBodyLength))
        draft.actions = draft.actions
            .prefix(max(0, request.constraints.maxActionCount))
            .map {
                NotificationActionDraft(
                    identifier: $0.identifier,
                    title: String($0.title.prefix(request.constraints.maxActionTitleLength)),
                    options: $0.options
                )
            }
        return draft
    }

    private func title(for request: FoundationNotify.Request) -> String {
        switch request.intent {
        case .reminder:
            return localized(request, japanese: "そろそろリマインド", english: "Time for a reminder")
        case .habit:
            return localized(request, japanese: "今日の習慣", english: "Your habit check-in")
        case .learning:
            return localized(request, japanese: "学びを続けよう", english: "Keep learning")
        case .wellness:
            return localized(request, japanese: "少し整えましょう", english: "Take a mindful pause")
        case .productivity:
            return localized(request, japanese: "次の一歩", english: "Your next step")
        case .event:
            return localized(request, japanese: "予定の時間です", english: "Event time")
        }
    }

    private func body(for request: FoundationNotify.Request) -> String {
        let context = normalizedContext(request.context)
        let prefix: String

        switch request.tone {
        case .friendly:
            prefix = localized(request, japanese: "今ならちょうどよさそうです。", english: "Now is a good moment.")
        case .gentle:
            prefix = localized(request, japanese: "無理なく少しだけ進めましょう。", english: "Take one gentle step.")
        case .energetic:
            prefix = localized(request, japanese: "勢いをつけて始めましょう。", english: "Start strong and build momentum.")
        case .professional:
            prefix = localized(request, japanese: "予定に沿って確認しましょう。", english: "Review this as planned.")
        case .playful:
            prefix = localized(request, japanese: "さあ、楽しく進めましょう。", english: "Make it a quick win.")
        case .calm:
            prefix = localized(request, japanese: "落ち着いて確認しましょう。", english: "Check in calmly.")
        }

        return "\(prefix) \(context)"
    }

    private func normalizedContext(_ context: String) -> String {
        let trimmed = context.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Open the app and take the next step."
        }
        return trimmed
    }

    private func actions(for request: FoundationNotify.Request) -> [NotificationActionDraft] {
        switch request.intent {
        case .reminder:
            return [
                NotificationActionDraft(identifier: "REVIEW_NOW", title: localized(request, japanese: "今すぐ確認", english: "Review now")),
                NotificationActionDraft(identifier: "LATER", title: localized(request, japanese: "あとで", english: "Later"))
            ]
        case .habit:
            return [
                NotificationActionDraft(identifier: "START_NOW", title: localized(request, japanese: "始める", english: "Start now"), options: [.foreground]),
                NotificationActionDraft(identifier: "SKIP_TODAY", title: localized(request, japanese: "今日はスキップ", english: "Skip today"))
            ]
        case .learning:
            return [
                NotificationActionDraft(identifier: "PRACTICE_NOW", title: localized(request, japanese: "練習する", english: "Practice now"), options: [.foreground])
            ]
        case .wellness:
            return [
                NotificationActionDraft(identifier: "TAKE_PAUSE", title: localized(request, japanese: "ひと休み", english: "Take a pause"))
            ]
        case .productivity:
            return [
                NotificationActionDraft(identifier: "OPEN_TASK", title: localized(request, japanese: "タスクを開く", english: "Open task"), options: [.foreground])
            ]
        case .event:
            return [
                NotificationActionDraft(identifier: "VIEW_EVENT", title: localized(request, japanese: "予定を見る", english: "View event"), options: [.foreground]),
                NotificationActionDraft(identifier: "SNOOZE", title: localized(request, japanese: "少し後で", english: "Snooze"))
            ]
        }
    }

    private func localized(_ request: FoundationNotify.Request, japanese: String, english: String) -> String {
        guard let identifier = request.locale?.identifier.localizedLowercase else {
            return english
        }
        return identifier.hasPrefix("ja") ? japanese : english
    }
}
