# Development Test Matrix

| Area | Check | Current result |
|---|---|---|
| Repository | Remote and default branch lookup | Passed |
| Scaffold | Flutter project generation | Passed |
| Formatting | `dart format lib test integration_test` | Passed; 52 files checked in the latest run |
| Static analysis | `flutter analyze --fatal-infos` | Passed; no issues found in the latest run |
| Unit/rule/widget tests | `flutter test` | Passed; 43 tests |
| Localization | parity, fallback, arguments, plurals, pseudolocale | Passed; 4 tests |
| BMC | accessible action, 48px target, allowlisted launch | Passed in widget tests |
| Android resources | XML parse plus AAPT2 compile/link against Android API 36 | Passed |
| Repository security | credential-pattern scan excluding generated/cache directories | Passed; no candidate credentials found |
| Licensing | resolved Dart package license-file and bundled-asset manifest review | Passed for the source alpha; repeat after dependency changes |
| Integration test source | `integration_test/app_test.dart` | Authored; not executed because no Android target/build is available |
| Android | `flutter build apk --debug` | Blocked before compilation while Gradle attempted a denied network download; approval retry rejected by environment usage limit |

Detailed test ownership and release evidence are added as features are implemented.
