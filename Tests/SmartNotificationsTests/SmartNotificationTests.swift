import Foundation
import XCTest
@testable import SmartNotifications

final class SmartNotificationTests: XCTestCase {
    func testGenerateValidatesDraft() async throws {
        let client = SmartNotificationClient(
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

        XCTAssertEqual(draft.title, "Review")
    }

    func testScheduleGeneratedDraftAfterInterval() async throws {
        let scheduler = MockNotificationScheduler()
        let client = SmartNotificationClient(
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

        XCTAssertEqual(identifier, "mock-notification-id")
        let scheduled = await scheduler.scheduled
        XCTAssertEqual(scheduled.count, 1)
        XCTAssertEqual(scheduled.first?.trigger, .timeInterval(1_800, repeats: false))
    }

    func testScheduleDraftAtDate() async throws {
        let scheduler = MockNotificationScheduler()
        let client = SmartNotificationClient(
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

        XCTAssertEqual(identifier, "mock-notification-id")
        let scheduled = await scheduler.scheduled
        XCTAssertEqual(scheduled.first?.trigger, .date(date))
    }

    func testRepeatingScheduleUsesCalendarTrigger() async throws {
        let scheduler = MockNotificationScheduler()
        let client = SmartNotificationClient(
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

        let trigger = await scheduler.scheduled.first?.trigger
        guard case let .calendar(components, repeats) = trigger else {
            return XCTFail("Expected calendar trigger")
        }
        XCTAssertTrue(repeats)
        XCTAssertEqual(components.hour, 8)
        XCTAssertEqual(components.minute, 0)
    }

    func testAuthorizationDelegatesToAuthorizer() async throws {
        let client = SmartNotificationClient(
            generator: MockNotificationGenerator(
                draft: NotificationDraft(title: "Review", body: "Review now.")
            ),
            scheduler: MockNotificationScheduler(),
            authorizer: MockNotificationAuthorizer(granted: true, status: .provisional)
        )

        let granted = try await client.requestAuthorization()
        XCTAssertTrue(granted)
        let status = await client.authorizationStatus()
        XCTAssertEqual(status, .provisional)
    }
}
