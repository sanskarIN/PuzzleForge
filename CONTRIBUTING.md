# Contributing to PuzzleForge

Thank you for improving PuzzleForge. By participating, you agree to follow the Code of Conduct and license your contribution under the repository's MIT License unless a file clearly states otherwise.

## Before opening a change

1. Search existing issues and discussions.
2. For a large feature, open a proposal describing player value, accessibility, deterministic behavior, persistence impact, tests, and asset licensing.
3. Never submit secrets, signing material, copied puzzle content, protected branding, or assets without redistribution rights.

## Development workflow

1. Fork the repository and create a focused branch.
2. Install the Flutter version documented in `pubspec.yaml`.
3. Keep user-facing text in the localization catalog.
4. Add or update tests for rules, serialization, UI, and regressions.
5. Run formatting, analysis, tests, and an Android debug build.
6. Update documentation and `CHANGELOG.md` when behavior changes.
7. Use a clear conventional commit such as `feat: add maze hints`.

## Puzzle module requirements

Every enabled module must have a stable ID and schema version, deterministic generation, legal-action validation, serialization round trips, a solved check, accessibility descriptions, difficulty documentation, hints that cannot double-charge, and tests for invalid inputs.

## Pull requests

Keep a pull request reviewable and explain player impact, architectural impact, validation, remaining risks, and all bundled asset licenses. Maintainers may request changes before accepting a contribution.
