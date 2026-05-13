# ``FoundationNotify``

Generate privacy-preserving local notification drafts on device and schedule them with UserNotifications.

## Overview

FoundationNotify provides typed notification generation, validation, authorization, and scheduling for local notifications. It can use Apple Foundation Models when available, with a deterministic fallback generator for unsupported environments and tests.

## Quick Start

Request authorization, generate a draft, and schedule it:

```swift
let granted = try await FoundationNotify.requestAuthorization()
guard granted else { return }

let draft = try await FoundationNotify.generate(
    context: "Review vocabulary flashcards.",
    tone: .friendly,
    intent: .reminder
)

try await FoundationNotify.schedule(draft, after: .minutes(30))
```

## Topics

### Essentials

- ``FoundationNotify/Client``
- ``FoundationNotify/Request``
- ``NotificationDraft``
- ``NotificationActionDraft``
- ``NotificationConstraints``
- ``NotificationValidator``

### Generation

- ``NotificationGenerating``
- ``FoundationModelsNotificationGenerator``
- ``FallbackNotificationGenerator``
- ``NotificationTone``
- ``NotificationIntent``

### Scheduling

- ``NotificationScheduling``
- ``UserNotificationScheduler``
- ``NotificationTrigger``

### Authorization

- ``NotificationAuthorizing``
- ``UserNotificationAuthorizationClient``

### Articles

- <doc:GettingStarted>
- <doc:FoundationModelsAvailability>
- <doc:NotificationActions>
