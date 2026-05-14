import Foundation
import Testing
@testable import FoundationNotify

struct FoundationNotifyTests {
    @Test func generateValidatesDraft() async throws {
        let client = FoundationNotify.Client(
            generator: MockNotificationGenerator(
                draft: NotificationDraft(title: "Review", body: "Review five words now.")
            ),
            scheduler: MockNotificationScheduler(),
            authorizer: MockNotificationAuthorizer()
        )

        let draft = try await client.generate(
            context: "vocabulary",
            tone: .friendly,
            intent: .learning
        )

        #expect(draft.title == "Review")
    }

    @Test func scheduleGeneratedDraftAfterInterval() async throws {
        let scheduler = MockNotificationScheduler()
        let client = FoundationNotify.Client(
            generator: MockNotificationGenerator(
                draft: NotificationDraft(title: "Review", body: "Review five words now.")
            ),
            scheduler: scheduler,
            authorizer: MockNotificationAuthorizer()
        )

        let identifier = try await client.schedule(
            after: .minutes(30),
            context: "vocabulary",
            tone: .friendly,
            intent: .learning
        )

        #expect(identifier == "mock-notification-id")
        let scheduled = await scheduler.scheduled
        #expect(scheduled.count == 1)
        #expect(scheduled.first?.trigger == .timeInterval(1_800, repeats: false))
    }

    @Test func scheduleDraftAtDate() async throws {
        let scheduler = MockNotificationScheduler()
        let client = FoundationNotify.Client(
            generator: MockNotificationGenerator(
                draft: NotificationDraft(title: "Unused", body: "Review now.")
            ),
            scheduler: scheduler,
            authorizer: MockNotificationAuthorizer()
        )
        let date = Date().addingTimeInterval(60)

        let identifier = try await client.schedule(
            NotificationDraft(title: "Walk", body: "Go for a short walk now."),
            at: date
        )

        #expect(identifier == "mock-notification-id")
        let scheduled = await scheduler.scheduled
        #expect(scheduled.first?.trigger == .date(date))
    }

    @Test func repeatingScheduleUsesCalendarTrigger() async throws {
        let scheduler = MockNotificationScheduler()
        let client = FoundationNotify.Client(
            generator: MockNotificationGenerator(
                draft: NotificationDraft(title: "Morning review", body: "Review words now.")
            ),
            scheduler: scheduler,
            authorizer: MockNotificationAuthorizer()
        )

        try await client.schedule(
            repeating: .daily(hour: 8, minute: 0),
            context: "morning vocabulary",
            tone: .friendly,
            intent: .reminder
        )

        let scheduled = await scheduler.scheduled
        let trigger = try #require(scheduled.first?.trigger)
        guard case let .calendar(components, repeats) = trigger else {
            #expect(Bool(false))
            return
        }
        #expect(repeats)
        #expect(components.hour == 8)
        #expect(components.minute == 0)
    }

    @Test func authorizationDelegatesToAuthorizer() async throws {
        let client = FoundationNotify.Client(
            generator: MockNotificationGenerator(
                draft: NotificationDraft(title: "Review", body: "Review now.")
            ),
            scheduler: MockNotificationScheduler(),
            authorizer: MockNotificationAuthorizer(granted: true, status: .provisional)
        )

        let granted = try await client.requestAuthorization()
        #expect(granted)
        let status = await client.authorizationStatus()
        #expect(status == .provisional)
    }
}
