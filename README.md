# FoundationNotify

AI-generated local notifications powered by Apple Foundation Models.

FoundationNotify is a Swift Package for generating privacy-preserving local notification copy on device and scheduling it with `UNUserNotificationCenter`. It targets Local Notifications only. It does not send remote Push Notifications, does not integrate with APNs, and does not require a notification server.

## Features

- Swift-native API for AI-generated local notifications.
- One-call generation and scheduling from user context, tone, intent, and schedule.
- Typed `NotificationDraft`, `NotificationTone`, `NotificationIntent`, constraints, triggers, and schedules.
- `NotificationGenerating`, `NotificationScheduling`, and `NotificationAuthorizing` protocols for dependency injection.
- Validation for empty copy, length limits, forbidden phrases, actionable copy, and invalid schedules.
- Async/await adapters for `UNUserNotificationCenter`.
- Foundation Models integration point isolated behind `NotificationGenerating`, with a deterministic fallback generator for builds and tests.

## Installation

Add the package to your Swift Package dependencies:

```swift
.package(url: "https://github.com/nyagasan/FoundationNotify.git", from: "0.1.0")
```

Then add the product to your target:

```swift
.product(name: "SmartNotifications", package: "FoundationNotify")
```

## Requirements

- Swift 5.9 or later.
- iOS 16+, macOS 13+, watchOS 9+, or tvOS 16+.
- `UserNotifications` for real scheduling.
- Apple Foundation Models availability depends on OS, device, and Xcode support. This package keeps Foundation Models usage behind `NotificationGenerating` so unsupported environments can still build and test with fallback or mock generators.

## Quick Start

Request notification permission first:

```swift
import SmartNotifications

let granted = try await SmartNotification.requestAuthorization()
guard granted else {
    return
}
```

Generate and schedule a local notification in one call:

```swift
try await SmartNotification.schedule(
    after: .minutes(30),
    context: "ユーザーは英単語学習中。復習を促したい。",
    tone: .friendly,
    intent: .reminder
)
```

## Generate Only

```swift
let draft = try await SmartNotification.generate(
    context: "ユーザーは英単語学習中。復習を促したい。",
    tone: .friendly,
    intent: .reminder
)
```

`NotificationDraft` contains the local notification copy and metadata:

```swift
public struct NotificationDraft: Sendable, Codable, Equatable {
    public var title: String
    public var body: String
    public var subtitle: String?
    public var categoryIdentifier: String?
    public var threadIdentifier: String?
    public var userInfo: [String: String]
}
```

## Schedule a Draft

```swift
let draft = try await SmartNotification.generate(
    context: "明日の朝、ユーザーに散歩を促したい。",
    tone: .gentle,
    intent: .habit
)

try await SmartNotification.schedule(
    draft,
    at: Date().addingTimeInterval(30 * 60)
)
```

## Schedule at a Date

```swift
try await SmartNotification.schedule(
    at: someDate,
    context: "明日の朝、ユーザーに散歩を促したい。",
    tone: .gentle,
    intent: .habit
)
```

## Repeating Schedule

```swift
try await SmartNotification.schedule(
    repeating: .daily(hour: 8, minute: 0),
    context: "朝の英単語復習を促す",
    tone: .friendly,
    intent: .reminder
)
```

You can also use weekly, monthly, or custom `DateComponents` schedules:

```swift
try await SmartNotification.schedule(
    draft,
    repeating: .weekly(weekday: 2, hour: 9, minute: 30)
)
```

## Authorization Status

```swift
let status = await SmartNotification.authorizationStatus()

switch status {
case .authorized, .provisional, .ephemeral:
    break
case .notDetermined:
    _ = try await SmartNotification.requestAuthorization()
case .denied, .unknown, .unsupported:
    break
}
```

## Constraints and Validation

```swift
let constraints = NotificationConstraints(
    maxTitleLength: 48,
    maxBodyLength: 140,
    forbiddenPhrases: ["limited time", "今すぐ課金"],
    requireActionableCopy: true
)

try await SmartNotification.schedule(
    after: .minutes(10),
    context: "短い復習セッションを促したい。",
    tone: .calm,
    intent: .learning,
    constraints: constraints
)
```

Validation failures are returned as `SmartNotificationError.validationFailed`.

## Dependency Injection

Use `SmartNotificationClient` when you want explicit dependencies, tests, or a custom Foundation Models generator.

```swift
struct MockGenerator: NotificationGenerating {
    func generateNotification(for request: SmartNotificationRequest) async throws -> NotificationDraft {
        NotificationDraft(
            title: "Review time",
            body: "Review five words now.",
            categoryIdentifier: request.intent.rawValue
        )
    }
}

let client = SmartNotificationClient(
    generator: MockGenerator(),
    scheduler: UserNotificationScheduler(),
    authorizer: UserNotificationAuthorizationClient()
)

try await client.schedule(
    after: .minutes(30),
    context: "Vocabulary review",
    tone: .friendly,
    intent: .learning
)
```

For unit tests, provide a mock `NotificationScheduling` implementation so tests do not call `UNUserNotificationCenter`.

## Foundation Models Availability

`FoundationModelsNotificationGenerator` is intentionally isolated. The current package does not unconditionally call undocumented or unavailable Foundation Models APIs, because those APIs vary by OS and Xcode version. In unsupported environments it delegates to `FallbackNotificationGenerator`.

When your app target has Foundation Models available, provide your own `NotificationGenerating` implementation using the Apple API surface supported by your deployment environment. That implementation can use structured generation and `@Generable` where available, then return `NotificationDraft`.

## Privacy

FoundationNotify is designed for on-device notification copy generation. User context should stay inside the app process when you use an on-device generator. The fallback generator is deterministic and does not perform network requests.

## Limitations

- This package schedules Local Notifications only.
- It does not send Push Notifications and does not integrate with APNs.
- Real notification delivery behavior is controlled by the OS, user settings, Focus modes, and notification permissions.
- Foundation Models support requires compatible Apple platform and toolchain availability.
- The fallback generator is intentionally simple and is meant for compatibility, tests, and graceful degradation.

## Roadmap

- Native Foundation Models generator using structured output and `@Generable` when the public API surface is stable in supported toolchains.
- Richer category/action modeling for notification actions.
- Additional locale-aware prompt and validation policies.
- Optional notification preview utilities for SwiftUI apps.
- More schedule helpers for common reminder patterns.
