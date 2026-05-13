import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Generates notification drafts with Apple Foundation Models and falls back when unavailable.
public struct FoundationModelsNotificationGenerator: NotificationGenerating {
    private let fallback: any NotificationGenerating
    private let usesFallbackWhenUnavailable: Bool

    public init(
        fallback: any NotificationGenerating = FallbackNotificationGenerator(),
        usesFallbackWhenUnavailable: Bool = true
    ) {
        self.fallback = fallback
        self.usesFallbackWhenUnavailable = usesFallbackWhenUnavailable
    }

    public func generateNotification(for request: FoundationNotify.Request) async throws -> NotificationDraft {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
            return try await generateWithFoundationModels(for: request)
        } else {
            return try await unavailableFallback(for: request)
        }
        #else
        return try await fallback.generateNotification(for: request)
        #endif
    }

    private func unavailableFallback(for request: FoundationNotify.Request) async throws -> NotificationDraft {
        guard usesFallbackWhenUnavailable else {
            throw FoundationNotify.Error.unsupportedPlatform
        }
        return try await fallback.generateNotification(for: request)
    }
}

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
private extension FoundationModelsNotificationGenerator {
    func generateWithFoundationModels(for request: FoundationNotify.Request) async throws -> NotificationDraft {
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            return try await unavailableFallback(for: request)
        }
        if let locale = request.locale, !model.supportsLocale(Locale(identifier: locale.rawValue)) {
            return try await unavailableFallback(for: request)
        }

        let session = LanguageModelSession(
            model: model,
            instructions: instructions(for: request)
        )
        let response = try await session.respond(
            to: prompt(for: request),
            generating: GeneratedNotificationDraft.self,
            includeSchemaInPrompt: true,
            options: GenerationOptions(temperature: temperature(for: request.tone), maximumResponseTokens: 180)
        )

        return response.content.notificationDraft(for: request)
    }

    func instructions(for request: FoundationNotify.Request) -> String {
        """
        You write concise local notification copy for an app.
        Generate only safe, truthful, actionable notification text.
        Do not claim urgency, discounts, medical advice, financial advice, or external facts unless they are present in the context.
        Match the requested tone and intent.
        Keep the title at or below \(request.constraints.maxTitleLength) characters and the body at or below \(request.constraints.maxBodyLength) characters.
        \(localeInstruction(for: request.locale))
        """
    }

    func prompt(for request: FoundationNotify.Request) -> String {
        """
        Context:
        \(request.context)

        Tone: \(request.tone.rawValue)
        Intent: \(request.intent.rawValue)

        Return a notification title, body, and up to \(request.constraints.maxActionCount) optional quick action buttons. The body must suggest one clear next action.
        """
    }

    func localeInstruction(for locale: LocaleIdentifier?) -> String {
        guard let locale else {
            return "Use the user's current app language."
        }
        return "Respond in the language appropriate for locale \(locale.rawValue)."
    }

    func temperature(for tone: NotificationTone) -> Double {
        switch tone {
        case .professional, .calm:
            return 0.4
        case .gentle, .friendly:
            return 0.6
        case .energetic, .playful:
            return 0.8
        }
    }
}

@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
@Generable(description: "A single notification action button")
private struct GeneratedAction: Sendable {
    @Guide(description: "A short uppercase snake_case identifier, e.g. REVIEW_NOW")
    let identifier: String

    @Guide(description: "A short user-facing button label.")
    let title: String

    @Guide(description: "Whether this action opens the app in the foreground.")
    let foreground: Bool
}

@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
@Generable(description: "A concise local notification draft with optional quick actions")
private struct GeneratedNotificationDraft: Sendable {
    @Guide(description: "A short notification title.")
    let title: String

    @Guide(description: "A concise notification body that contains one clear next action.")
    let body: String

    @Guide(description: "Up to 3 quick action buttons. Empty list is acceptable.")
    let actions: [GeneratedAction]

    func notificationDraft(for request: FoundationNotify.Request) -> NotificationDraft {
        NotificationDraft(
            title: String(title.prefix(request.constraints.maxTitleLength)),
            body: String(body.prefix(request.constraints.maxBodyLength)),
            categoryIdentifier: request.intent.rawValue,
            threadIdentifier: "smart-notification-\(request.intent.rawValue)",
            userInfo: [
                "source": "FoundationNotify",
                "generator": "FoundationModels",
                "intent": request.intent.rawValue,
                "tone": request.tone.rawValue
            ],
            actions: actions
                .prefix(max(0, request.constraints.maxActionCount))
                .map { action in
                    var options: NotificationActionDraft.Options = []
                    if action.foreground {
                        options.insert(.foreground)
                    }
                    return NotificationActionDraft(
                        identifier: action.identifier,
                        title: String(action.title.prefix(request.constraints.maxActionTitleLength)),
                        options: options
                    )
                }
        )
    }
}
#endif
