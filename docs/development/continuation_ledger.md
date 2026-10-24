# Continuation Ledger

## Resume pointer

- Date: 2026-10-24
- Phase: 5 — QA and release hardening
- Version: 0.1.0+1
- Last completed work: compatible Puzzle Path rename, creator/support updates, protected signing, save race fixes, Continue/foreground recovery, and streak fixes.
- Source validation: 55 tests pass; strict analysis and formatting pass on Flutter 3.47.0 / Dart 3.13.0.
- Next task: review the [PR stack](review_register.md), inspect [Android artifacts](../release/android_artifacts.md), then run the device matrix and configure protected release signing.
- External requirements: maintainer upload key, Android test device/emulator, Play Console/store assets, and final legal review.
- Remaining implementation: audio/haptics/notifications, authored campaigns/locks, mastery/missions, and future migrations. See [project status](../../PROJECT_STATUS.md).

## Stable decisions

- Product: Puzzle Path (formerly PuzzleForge); Dart package: puzzle_path
- Stack: Flutter/Dart, local-first Android application
- Application ID: com.sanskarin.puzzleforge, retained for installation compatibility
- Preferences/backup/seed namespaces retain their original identifiers
- Repository: https://github.com/sanskarIN/PuzzleForge
- Website: https://sanskarin.github.io
- Support: https://buymeacoffee.com/SanskarCodes, https://razorpay.me/@SanskarCodes, https://paypal.me/SanskarCodes
- Main email: sanskarcodes@gmail.com; business: sanskar.businesswork@gmail.com
- License: MIT for original code/assets, with separate third-party notices
- Git author email: sanskarin@outlook.in
