# Foundation Models Availability

FoundationNotify checks Apple Foundation Models availability before attempting model-backed generation.

## Availability Flow

``FoundationModelsNotificationGenerator`` uses `SystemLanguageModel.default.availability` on supported Apple platform versions. If the model is unavailable, the platform version is unsupported, the requested locale is not supported, or `FoundationModels` cannot be imported, it delegates to ``FallbackNotificationGenerator`` by default.

## Strict Mode

Use strict mode when fallback generation should not run:

```swift
let generator = FoundationModelsNotificationGenerator(
    usesFallbackWhenUnavailable: false
)
```

In strict mode, unsupported environments throw ``FoundationNotify/Error/unsupportedPlatform``.

## Custom Fallback

```swift
let generator = FoundationModelsNotificationGenerator(
    fallback: MyGenerator(),
    usesFallbackWhenUnavailable: true
)
```
