# Development Test Matrix

| Area | Check | Current result |
|---|---|---|
| Repository | Remote and default branch lookup | Passed |
| Scaffold | Flutter project generation | Passed |
| Formatting | `dart format lib test integration_test` | Passed; 52 files checked in the latest run |
| Static analysis | `flutter analyze --fatal-infos` | Passed; no issues found in the latest run |
| Unit/rule/widget tests | `flutter test` | Passed; 42 tests |
| Localization | parity, fallback, arguments, plurals, pseudolocale | Passed; 4 tests |
| BMC | accessible action, 48px target, allowlisted launch | Passed in widget tests |
| Integration test source | `integration_test/app_test.dart` | Authored; not executed because no Android target/build is available |
| Android | `flutter build apk --debug` | Blocked before compilation while Gradle attempted a denied network download; approval retry rejected by environment usage limit |

Detailed test ownership and release evidence are added as features are implemented.
