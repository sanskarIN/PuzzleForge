# Changelog

All notable changes follow Keep a Changelog principles. This project uses semantic versioning after its first stable release.

## [Unreleased]

### Changed — 24 October 2026

- Renamed the app to Puzzle Path, preserving Android/data/backup/seed compatibility.
- Updated the website, BMC destination, main/business emails, and added Razorpay/PayPal support.
- Restricted external launches to registered destinations and added a copy-link fallback.
- Added protected upload signing and a required-signing guard; CI pins Flutter 3.47.0/JDK 17.
- Reconciled project status and roadmap with actual source and remaining release gates.

### Fixed — 24 October 2026

- Pending saves recreating deleted data and settings writes finishing out of order.
- Replays changing completion records before persistence finished.
- Saved puzzles staying paused, foreground timers not resuming, and inconsistent injected clocks.
- Backwards streak dates and daylight-saving civil-day comparisons.
- Date-sensitive home smoke selectors; the full suite now passes 55 tests.

### Added

- Flutter Android project foundation.
- Continuity ledger, phase status, known-issues register, and initial test matrix.
- Open-source community, security, privacy, legal, release, architecture, design, and support documentation.
- Eight deterministic, verified puzzle modules with shared undo/redo, hints, replay, scoring, persistence, and accessibility contracts.
- Responsive Material 3 home, catalog, daily, campaign, endless, gameplay, results, favorites, history, statistics, achievements, streak, themes, tutorial, guide, settings, support, about, legal, developer, and puzzle-editor screens.
- English, Hindi, and expanded pseudolocalization support.
- Local settings, progress, integrity-checked backups, safe external links, original BMC support experience, and original Android branding.

## [0.1.0] — In development

- Initial repository bootstrap.
