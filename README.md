# FoundationNotify

[![Swift](https://github.com/nyagasan/FoundationNotify/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/nyagasan/FoundationNotify/actions/workflows/swift.yml)
![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)
![Xcode 26](https://img.shields.io/badge/Xcode-26-1575F9.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS%2026%20%7C%20macOS%2026%20%7C%20watchOS%2026%20%7C%20tvOS%2026%20%7C%20visionOS%2026-lightgrey.svg)

AI-generated local notifications powered by Apple Foundation Models.

FoundationNotify is a Swift Package for generating privacy-preserving local notification copy on device and scheduling it with `UNUserNotificationCenter`. It targets Local Notifications only. It does not send remote Push Notifications, does not integrate with APNs, and does not require a notification server.

## Features

- Swift-native API for AI-generated local notifications.
- One-call generation and scheduling from user context, tone, intent, and schedule.
- Typed `NotificationDraft`, `NotificationTone`, `NotificationIntent`, constraints, triggers, and schedules.
- `NotificationGenerating`, `NotificationScheduling`, and `NotificationAuthorizing` protocols for dependency injection.
- Validation for empty copy, length limits, forbidden phrases, actionable copy, and invalid schedules.
- Async/await adapters for `UNUserNotificationCenter`.
- Foundation Models structured generation via `@Generable` and `LanguageModelSession`, with a deterministic fallback generator for unavailable devices and tests.

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

- Xcode 26 or later.
- Swift 6 language mode.
- iOS 26+, macOS 26+, watchOS 26+, tvOS 26+, or visionOS 26+.
- `UserNotifications` for real scheduling.
- Apple Foundation Models on iOS 26 and sibling OS releases. Runtime model availability still depends on Apple Intelligence support, user settings, and model readiness.

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

`FoundationModelsNotificationGenerator` uses the WWDC25 GA Foundation Models API surface: `SystemLanguageModel.default.availability`, `LanguageModelSession`, guided structured generation with `@Generable` and `@Guide`, and `respond(to:generating:includeSchemaInPrompt:options:)`.

The generator checks model availability before creating a response. If Foundation Models cannot be imported, the OS is below the supported availability, or `SystemLanguageModel` is unavailable at runtime, it delegates to `FallbackNotificationGenerator` by default.

```swift
// Default: auto-fallback when the on-device model is unavailable.
let generator = FoundationModelsNotificationGenerator()

// Strict mode: throw SmartNotificationError.unsupportedPlatform instead of falling back.
let strict = FoundationModelsNotificationGenerator(
    usesFallbackWhenUnavailable: false
)

let client = SmartNotificationClient(
    generator: strict,
    scheduler: UserNotificationScheduler(),
    authorizer: UserNotificationAuthorizationClient()
)
```

You can also inject a custom fallback (for example, a server-backed generator behind a feature flag):

```swift
let generator = FoundationModelsNotificationGenerator(
    fallback: MyRemoteGenerator(),
    usesFallbackWhenUnavailable: true
)
```

## Privacy

FoundationNotify is designed for on-device notification copy generation. User context should stay inside the app process when you use an on-device generator. The fallback generator is deterministic and does not perform network requests.

The Foundation Models implementation uses Apple’s on-device Foundation Models framework introduced as a public WWDC25 API. It does not add a server dependency or send notification context to a package-owned backend.

## Limitations

- This package schedules Local Notifications only.
- It does not send Push Notifications and does not integrate with APNs.
- Real notification delivery behavior is controlled by the OS, user settings, Focus modes, and notification permissions.
- Foundation Models support requires Xcode 26, compatible Apple platform availability, Apple Intelligence support, and a ready on-device model.
- The fallback generator is intentionally simple and is meant for compatibility, tests, and graceful degradation.

## Roadmap

- Richer category/action modeling for notification actions.
- Additional locale-aware prompt and validation policies.
- Optional notification preview utilities for SwiftUI apps.
- More schedule helpers for common reminder patterns.

## Continuous Integration

CI runs on GitHub Actions with the `macos-15` runner and Xcode 26.3. `swift build` is invoked with `-warnings-as-errors` to catch Swift 6 strict-concurrency regressions, and the test suite runs on the iOS 26 Simulator (the runner host is still macOS 15 and cannot dlopen `FoundationModels.framework`, which only ships in macOS 26 / iOS 26 SDKs). See `.github/workflows/swift.yml`.

## License

License: TBD. The repository does not yet include a `LICENSE` file; choose and add one before publishing the package as a dependency.
