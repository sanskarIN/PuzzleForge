# Resolved Dependency and Asset Review

Review date: 2026-08-14

Scope: version `0.1.0+1` source alpha, resolved by `pubspec.lock` with Flutter 3.44.7 and Dart 3.12.2.

## Direct runtime dependencies

| Dependency | Resolved version | Purpose | License family checked in package source |
|---|---:|---|---|
| Flutter SDK | 3.44.7 | UI, rendering, accessibility, Android embedding | BSD-3-Clause |
| `crypto` | 3.0.7 | SHA-256 seeds and backup integrity | BSD-3-Clause |
| `intl` | 0.20.2 | Locale-aware date and number formatting | BSD-3-Clause |
| `shared_preferences` | 2.5.5 | Local settings and compact save records | BSD-3-Clause |
| `url_launcher` | 6.3.2 | User-initiated allowlisted HTTPS and mail links | BSD-3-Clause |

Development-only dependencies are Flutter SDK test/integration libraries and `flutter_lints` 6.0.0. The resolved graph was enumerated with `flutter pub deps --style=compact`; every external package root in the active package configuration exposed a license file, while Flutter SDK subpackages are covered by the SDK distribution license. Observed external package licenses were permissive BSD-style or Apache-2.0 licenses and compatible with distributing the original project under MIT.

The complete direct attribution remains in `THIRD_PARTY_NOTICES.md`. Flutter generates runtime license notices from package license files for application distribution. This review must be repeated after every dependency or SDK change and against the final Android dependency graph before a release candidate.

## Assets

Every bundled file under `assets/` is listed in `assets/branding/ASSET_LICENSES.md`. The two support cards and Android forge-grid vectors are original project artwork under MIT. The artwork intentionally avoids copying the Buy Me a Coffee logo.

## Result

Passed for the source-alpha dependency snapshot. This is an engineering compatibility review, not legal advice; commercial publication still requires the legal-review gate.
