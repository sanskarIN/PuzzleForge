# Release Test Matrix

| Layer | Required evidence | Owner/state |
|---|---|---|
| Pure domain | Generator determinism, invariants, rules, solver/verifier, scoring | Automated; pending implementation |
| Session | Undo/redo, replay, timer, hint idempotency, serialization | Automated; pending implementation |
| Persistence | Round trip, corrupt data, migration, import size/checksum | Automated; pending implementation |
| Localization | English/Hindi key parity, fallback, plurals, long text | Automated + manual; pending |
| Widgets | Home, navigation, boards, BMC, settings, semantics | Automated; pending |
| Integration | Startup, complete/save/resume, daily, backup | Automated/emulator; pending |
| Accessibility | TalkBack, large text, contrast, reduced motion, targets | Manual physical/emulator; pending |
| Android | Debug APK, signed AAB, background/resume, orientations | CI + release environment; pending |
| Performance | Frame timing, generator bounds, memory pressure | Profile build/device; pending |
| Security/legal | Import fuzzing, intent allowlist, secrets, licenses | Automated + review; pending |

Executed outcomes are mirrored in `docs/development/test_matrix.md`; this file defines the release obligation.
