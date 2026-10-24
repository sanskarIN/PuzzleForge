# Puzzle Path

**Think deeper. Solve smarter.**

Puzzle Path is an open-source, offline-first puzzle collection built with Flutter for Android. It provides deterministic daily challenges, accessible board interactions, local progress, undo/redo, hints, and a modular engine designed for new puzzle types.

> Made by the Sanskar

Previously called PuzzleForge. The public app name is now **Puzzle Path**. The Android application ID, saved-data keys, backup format, and versioned puzzle seeds retain their original identifiers so existing installations and backups remain compatible. The repository remains at `sanskarIN/PuzzleForge`.

## Project state

Puzzle Path is under active development. See [PROJECT_STATUS.md](PROJECT_STATUS.md), [ROADMAP.md](ROADMAP.md), and [what_changed.md](what_changed.md) before treating a build as release-ready.

## Highlights

- Deterministic, versioned puzzle generation with solvability checks
- A shared puzzle contract for actions, serialization, hints, scores, accessibility descriptions, undo, and redo
- English and Hindi localization with runtime switching
- System, light, dark, high-contrast, and reduced-motion preferences
- Local-only settings, history, favorites, achievements, statistics, streaks, and saved sessions
- Phone, tablet, portrait, and landscape-aware Material 3 UI
- No account, advertising SDK, analytics SDK, or remote game service

## Run locally

Prerequisites: Flutter 3.44.7 or newer stable (before Flutter 4), Dart 3.12.2 or newer compatible stable, Android Studio/Android SDK, JDK 17, and an Android device or emulator.

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
```

Run the app with `flutter run`. Release signing credentials must stay outside Git; follow [the Android release guide](docs/release/android_release.md).

## Support the project

[Support this project — Buy Me a Coffee](https://buymeacoffee.com/SanskarCodes). Donations are optional, do not unlock gameplay, and do not receive guaranteed feature priority.

- Website: [sanskarin.github.io](https://sanskarin.github.io)
- Creator: [Sanskar on GitHub](https://github.com/sanskarIN)
- Main email and support: [sanskarcodes@gmail.com](mailto:sanskarcodes@gmail.com)
- Business: [sanskar.businesswork@gmail.com](mailto:sanskar.businesswork@gmail.com)
- Razorpay: [Support SanskarCodes](https://razorpay.me/@SanskarCodes)
- PayPal: [Support SanskarCodes](https://paypal.me/SanskarCodes)

All support links open an external app after a deliberate tap. Puzzle Path includes no payment SDK and does not process payments, track donations, or grant gameplay rewards for support. Git commits use `sanskarin@outlook.in` as the author email.

## Open source

Original code and original project artwork are licensed under the [MIT License](LICENSE). Third-party packages retain their own licenses; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Contributions are welcome under [CONTRIBUTING.md](CONTRIBUTING.md) and the [Code of Conduct](CODE_OF_CONDUCT.md).

Security reports should follow [SECURITY.md](SECURITY.md). Legal and privacy documents are developer-prepared templates requiring professional review before commercial publication.
