import Foundation
import Observation
#if canImport(FoundationModels)
import FoundationModels
#endif
import FoundationNotify
@preconcurrency import UserNotifications

@MainActor
@Observable
final class FoundationNotifyViewModel {
    var context = "Remind me to review the FoundationNotify sample notification flow in one minute."
    var tone: NotificationTone = .friendly
    var intent: NotificationIntent = .reminder
    var delayMinutes: Double = 1

    private(set) var authorizationStatusText = "unknown"
    private(set) var foundationModelsStatusText = "checking"
    private(set) var systemLanguageModelAvailabilityText: String?
    private(set) var latestDraft: NotificationDraft?
    private(set) var lastErrorMessage: String?
    private(set) var lastScheduledIdentifier: String?
    private(set) var pendingRequests: [PendingNotificationSummary] = []
    private(set) var isRunning = false

    func refresh() async {
        authorizationStatusText = await FoundationNotify.authorizationStatus().rawValue
        refreshFoundationModelsStatus()
        await refreshPendingRequests()
    }

    func requestPermission() async {
        await run {
            let granted = try await FoundationNotify.requestAuthorization()
            authorizationStatusText = await FoundationNotify.authorizationStatus().rawValue
            lastErrorMessage = granted ? nil : "Notification permission was not granted."
            await refreshPendingRequests()
        }
    }

    func generateDraft() async {
        await run {
            latestDraft = try await FoundationNotify.generate(
                context: context,
                tone: tone,
                intent: intent
            )
        }
    }

    func generateAndSchedule() async {
        await run {
            let identifier = try await FoundationNotify.schedule(
                after: .minutes(delayMinutes),
                context: context,
                tone: tone,
                intent: intent
            )
            lastScheduledIdentifier = identifier
            await refreshPendingRequests()
        }
    }

    private func run(_ operation: () async throws -> Void) async {
        isRunning = true
        lastErrorMessage = nil
        defer { isRunning = false }

        do {
            try await operation()
        } catch let error as FoundationNotify.Error {
            lastErrorMessage = message(for: error)
        } catch {
            lastErrorMessage = String(describing: error)
        }
    }

    private func refreshFoundationModelsStatus() {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            foundationModelsStatusText = "available to import"
            systemLanguageModelAvailabilityText = String(describing: SystemLanguageModel.default.availability)
        } else {
            foundationModelsStatusText = "requires iOS 26"
            systemLanguageModelAvailabilityText = nil
        }
        #else
        foundationModelsStatusText = "FoundationModels import unavailable"
        systemLanguageModelAvailabilityText = nil
        #endif
    }

    private func refreshPendingRequests() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        pendingRequests = requests.map { request in
            PendingNotificationSummary(
                identifier: request.identifier,
                title: request.content.title,
                body: request.content.body
            )
        }
    }

    private func message(for error: FoundationNotify.Error) -> String {
        switch error {
        case let .generationFailed(message):
            return "generationFailed: \(message)"
        case let .validationFailed(issues):
            return "validationFailed: \(issues.map(String.init(describing:)).joined(separator: ", "))"
        case .authorizationDenied:
            return "authorizationDenied: enable notifications in Settings and try again."
        case let .schedulingFailed(message):
            return "schedulingFailed: \(message)"
        case let .invalidSchedule(message):
            return "invalidSchedule: \(message)"
        case .unsupportedPlatform:
            return "unsupportedPlatform: Foundation Models is unavailable on this device or OS."
        }
    }
}

struct DelayOption: Identifiable, CaseIterable {
    let minutes: Double
    let label: String

    var id: Double { minutes }

    static let allCases: [DelayOption] = [
        DelayOption(minutes: 0.5, label: "30 seconds"),
        DelayOption(minutes: 1, label: "1 minute"),
        DelayOption(minutes: 5, label: "5 minutes"),
        DelayOption(minutes: 30, label: "30 minutes"),
        DelayOption(minutes: 60, label: "60 minutes")
    ]
}

struct PendingNotificationSummary: Identifiable {
    let identifier: String
    let title: String
    let body: String

    var id: String { identifier }
}
