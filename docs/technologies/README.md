# Technology Catalog

| Technology | Role | Version policy |
|---|---|---|
| Flutter | UI, rendering, Android application shell | Pinned stable version in `pubspec.yaml`/CI |
| Dart | Domain logic, state, tests | Bundled with pinned Flutter |
| Kotlin/Gradle | Android host and build | Generated/maintained by Flutter stable |
| SharedPreferences | Small versioned local JSON records | Locked in `pubspec.lock` |
| URL Launcher | Explicit external HTTPS/mailto intents | Locked in `pubspec.lock` |

Each major component has setup, debugging, licensing, and upgrade notes in this directory. New services require their own document before integration.
