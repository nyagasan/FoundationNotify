# Getting Started

Install FoundationNotify with Swift Package Manager, request notification authorization, generate a draft, and schedule it as a local notification.

## Installation

Add the package dependency:

```swift
.package(url: "https://github.com/nyagasan/FoundationNotify.git", from: "0.1.0")
```

Then add the product:

```swift
.product(name: "FoundationNotify", package: "FoundationNotify")
```

## Request Authorization

```swift
let granted = try await FoundationNotify.requestAuthorization()
guard granted else { return }
```

## Generate

```swift
let draft = try await FoundationNotify.generate(
    context: "The user is learning vocabulary and should review.",
    tone: .friendly,
    intent: .reminder
)
```

## Schedule

```swift
try await FoundationNotify.schedule(draft, after: .minutes(30))
```

For direct scheduling from context:

```swift
try await FoundationNotify.schedule(
    after: .minutes(30),
    context: "The user is learning vocabulary and should review.",
    tone: .friendly,
    intent: .reminder
)
```
