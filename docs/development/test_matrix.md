# Development Test Matrix

Source checks below were refreshed on **24 October 2026** with Flutter 3.47.0 / Dart 3.13.0. Android artifacts and signing status have their own dated register.

| Area | Check | Current result |
|---|---|---|
| Repository | Remote and default branch lookup | Passed |
| Scaffold | Flutter project generation | Passed |
| Formatting | `dart format lib test integration_test` | Passed; 56 files checked, no remaining changes |
| Static analysis | `flutter analyze --fatal-infos` | Passed; no issues found in the latest run |
| Unit/rule/widget tests | `flutter test --no-pub --reporter expanded` | Passed; 55 tests |
| Localization | parity, fallback, arguments, plurals, pseudolocale | Passed; 4 tests |
| BMC | accessible action, 48px target, allowlisted launch | Passed in widget tests |
| Creator/support links | Requested destinations, altered URI rejection, launch failure, clipboard fallback | Passed; website/BMC/Razorpay/PayPal/main/business actions covered |
| Support layout | Hindi, 390px screen, 2x text | Passed in widget test; device review pending |
| Save races | Gated I/O for deletion, settings order, completion/replay | Three regressions reproduced before the fix; all pass after |
| Session lifecycle | Restored Continue-to-result, automatic foreground resume, preserved manual pause | Passed in widget tests; Android device run pending |
| Daily streak | Backwards completion date, same-day/consecutive/gap behavior | Passed; civil-day comparison avoids DST duration arithmetic |
| Protected signing guard | Gradle help with requireReleaseSigning=true and no key file | Passed negative check; expected missing-key error |
| Android resources | XML parse plus AAPT2 compile/link against Android API 36 | Passed |
| Repository security | credential-pattern scan excluding generated/cache directories | Passed; no candidate credentials found |
| Licensing | resolved Dart package license-file and bundled-asset manifest review | Passed for the source alpha; repeat after dependency changes |
| Integration test source | `integration_test/app_test.dart` | Authored; Android device execution remains pending |
| Android debug artifact | Gradle `assembleDebug --no-daemon --offline` with JDK 17 | Passed; APK produced and hashed in `docs/release/android_artifacts.md` |
| Android release APK | Gradle `assembleRelease --no-daemon --offline` with JDK 17 | Passed; unsigned APK produced and hashed in `docs/release/android_artifacts.md` |
| Android release bundle | Gradle `bundleRelease --no-daemon --offline` with JDK 17 | Passed; unsigned AAB produced and hashed in `docs/release/android_artifacts.md` |
| Android device/instrumentation | Emulator or physical device | Pending; includes integration test, TalkBack, lifecycle, orientation, low-memory, and performance checks |

Detailed test ownership and release evidence are added as features are implemented.
