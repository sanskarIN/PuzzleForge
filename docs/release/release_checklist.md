# Release Checklist

## Automated gates

- [ ] Formatter reports no changes
- [ ] Analyzer reports zero errors and zero infos under project policy
- [ ] Unit, rule, deterministic, serialization, migration, localization, and widget tests pass
- [ ] Android debug APK builds
- [ ] Signed release AAB builds in the protected release environment
- [ ] Dependency and asset-license review is complete
- [ ] Secret scan and generated-artifact review pass

## Manual gates

- [ ] TalkBack, large text, high contrast, reduced motion, keyboard/switch paths tested
- [ ] Phone, tablet, portrait, landscape, background/resume, and low-memory smoke tests pass
- [ ] Every enabled generator produces verified solvable samples across difficulties
- [ ] Save/resume, undo/redo, stable daily seed, hint charging, and idempotent progression verified
- [ ] External BMC, GitHub, and email links work and fail gracefully
- [ ] Privacy, terms, store listing, content rating, data safety, and legal review complete
- [ ] Adaptive icon, splash, screenshots, version code, signing, R8, backup rules, and target SDK reviewed

Do not call a build a release candidate until every mandatory item has recorded evidence in `docs/testing/test_matrix.md`.
