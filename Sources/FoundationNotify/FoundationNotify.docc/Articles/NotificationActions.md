# Notification Actions

Use ``NotificationActionDraft`` to attach structured quick action buttons to a ``NotificationDraft``.

## Create a Draft With Actions

```swift
let draft = NotificationDraft(
    title: "Review time",
    body: "Review five words now.",
    categoryIdentifier: "vocabulary-review",
    actions: [
        NotificationActionDraft(
            identifier: "REVIEW_NOW",
            title: "Review now",
            options: [.foreground]
        ),
        NotificationActionDraft(
            identifier: "LATER",
            title: "Later"
        )
    ]
)
```

## Validation

``NotificationValidator`` checks action count, empty identifiers, duplicate identifiers, and action title length using ``NotificationConstraints``.

```swift
let constraints = NotificationConstraints(
    maxActionCount: 3,
    maxActionTitleLength: 24
)
```

## Scheduling

When a draft has actions, ``UserNotificationScheduler`` registers a `UNNotificationCategory` with existing categories preserved, then assigns the category identifier to the notification content.
