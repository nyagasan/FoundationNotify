#if canImport(FoundationModels)
import FoundationModels
#endif

public struct FoundationModelsNotificationGenerator: NotificationGenerating {
    private let fallback: any NotificationGenerating

    public init(fallback: any NotificationGenerating = FallbackNotificationGenerator()) {
        self.fallback = fallback
    }

    public func generateNotification(for request: SmartNotificationRequest) async throws -> NotificationDraft {
        #if canImport(FoundationModels)
        // Foundation Models API availability is still platform and Xcode dependent.
        // Keep this implementation behind the protocol boundary so package clients can
        // swap in a concrete generator without breaking environments that cannot import it.
        return try await fallback.generateNotification(for: request)
        #else
        return try await fallback.generateNotification(for: request)
        #endif
    }
}
