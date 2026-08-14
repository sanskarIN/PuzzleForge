# PuzzleForge 0.1.0+1 Source Alpha

Release status: source alpha, not a production release candidate. Android artifact, device, accessibility, performance, signing, and store-review gates remain open.

## Highlights

- Eight playable deterministic puzzle modules: Sliding Tiles, Number Merge, Light Grid, Maze, Sudoku, Memory Match, Color Sort, and Number Sequence.
- Offline Daily Puzzle, campaign, endless and custom-seed entry points, favorites, continue, history, achievements, statistics, streaks, XP, stars, levels, and hint tokens.
- Shared legal-action, undo/redo, replay, timer, hint, score, serialization, validation, and accessibility contracts.
- Responsive Material 3 interfaces for phones, tablets, portrait, and landscape, with system/light/dark themes and game-theme choices.
- English and Hindi catalogs, runtime language switching, fallback behavior, plural/date/number helpers, missing-key parity checks, and an expanded `en-XA` pseudolocale.
- Local-first persistence, corruption-safe recovery, integrity-checked JSON backup envelopes, versioned imports, and strict allowlisted external links.
- Original adaptive/round/legacy Android launcher art, Android 12 splash resources, an original BMC support card, and a permanent creator credit.
- Developer tools and a creator editor for deterministic preview, validation, import, export, duplicate-ID protection, and localization metadata.

## Verification evidence

- `dart format lib test integration_test`: passed for 52 files.
- `flutter analyze --fatal-infos`: passed with no issues.
- `flutter test -r expanded`: passed all 43 tests.
- Android XML parsing and AAPT2 resource compile/link against API 36: passed.
- Credential-pattern scan: no candidate credentials found.
- Resolved Dart dependency license-file and bundled-asset manifest review: passed for this source snapshot.

`flutter build apk --debug` could not finish because Gradle required a network artifact and the execution sandbox denied that connection; the approval retry was rejected by the environment usage limit. No Android build success is claimed. See `docs/development/known_issues.md` and `docs/testing/test_matrix.md` before distribution.

## Privacy and support

This alpha has no account, ad SDK, analytics SDK, purchase SDK, leaderboard, cloud save, or remote gameplay service. Settings and game progress stay in application-local storage; external links open only after a user action.

Made by the Sanskar.

[Support this project — Buy Me a Coffee](https://buymeacoffee.com/sanskarIN). Support is optional and never unlocks gameplay or guarantees feature priority.
