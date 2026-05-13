# FoundationNotify Sample App

Minimal iOS sample app for validating `FoundationNotify` on a real device with Apple Foundation Models.

## Requirements

- Xcode 26+
- iOS 26 device
- XcodeGen (`brew install xcodegen`)
- Your Apple Developer Team

## Setup

```sh
cd Examples/FoundationNotifySampleApp
xcodegen generate
open FoundationNotifySampleApp.xcodeproj
```

## Before First Run

1. Select your Team in Signing & Capabilities.
2. Change the Bundle Identifier from `com.example.foundationnotify.sample` to one under your own prefix.
3. Connect an iOS 26 device and run the app from Xcode.

## Foundation Models Notes

`SystemLanguageModel` may be unavailable in the simulator, which can cause the library fallback path to run. The real Foundation Models path is expected on an iOS 26 device that supports Apple Intelligence and has the required device settings enabled.

## Troubleshooting

- Notification does not appear: enable notifications for the app in Settings and check Focus Mode.
- `unsupportedPlatform`: Foundation Models is unavailable on the current OS or device. Retry with the fallback path, or verify the device, OS version, and Apple Intelligence settings.
