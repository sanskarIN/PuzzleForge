# Release Checklist

## Automated gates

- [x] Formatter reports no changes
- [x] Analyzer reports zero errors and zero infos under project policy
- [x] Unit, rule, deterministic, serialization, migration, localization, and widget tests pass
- [x] Android debug APK builds
- [x] Unsigned release APK and AAB compile with release lint passing
- [ ] Signed release AAB builds in the protected release environment
- [x] Resolved Dart dependency and bundled-asset license review is complete
- [x] Secret-pattern scan and generated-artifact review pass

## Manual gates

- [ ] TalkBack, large text, high contrast, reduced motion, keyboard/switch paths tested
- [ ] Phone, tablet, portrait, landscape, background/resume, and low-memory smoke tests pass
- [ ] Every enabled generator produces verified solvable samples across difficulties
- [ ] Save/resume, undo/redo, stable daily seed, hint charging, and idempotent progression verified
- [ ] External website, BMC, Razorpay, PayPal, GitHub, and email links work on devices and fail gracefully (automated destination/fallback tests pass)
- [ ] Privacy, terms, store listing, content rating, data safety, and legal review complete
- [ ] Adaptive icon, splash, screenshots, version code, signing, R8, backup rules, and target SDK reviewed

Do not call a build a release candidate until every mandatory item has recorded evidence in `docs/testing/test_matrix.md`.

The checked automated items and unsigned Android artifacts were verified on 2026-09-02. Signing and manual-device items remain intentionally unchecked, so version `0.1.0+1` is a source alpha rather than a release candidate.

Refreshed on 24 October 2026: 55 tests, strict formatter/analyzer, source credential-pattern scan, debug APK, and unsigned release APK/AAB pass their local gates. The debug signature verifies; release APK/AAB are confirmed unsigned. The production-signing guard rejects missing key configuration. Artifact hashes are in `android_artifacts.md`; signing and device/store gates remain open.
