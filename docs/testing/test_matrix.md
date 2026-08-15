# Release Test Matrix

| Layer | Required evidence | Owner/state |
|---|---|---|
| Pure domain | Generator determinism, invariants, rules, solver/verifier, scoring | Automated; passed in 43-test suite |
| Session | Undo/redo, replay, timer, hint idempotency, serialization | Automated; passed |
| Persistence | Round trip, corrupt data, migration, import size/checksum | Automated; passed for current schema, corruption, and checksum |
| Localization | English/Hindi key parity, fallback, plurals, pseudolocale, long text | Automated catalog tests passed; manual linguistic/large-text device review pending |
| Widgets | Home, navigation, boards, BMC, settings, semantics | Automated smoke/semantics tests passed |
| Integration | Startup, complete/save/resume, daily, backup | Android journey authored; device execution pending |
| Accessibility | TalkBack, large text, contrast, reduced motion, targets | Manual physical/emulator; pending |
| Android | Debug APK, signed AAB, background/resume, orientations | CI + release environment; pending |
| Performance | Frame timing, generator bounds, memory pressure | Profile build/device; pending |
| Security/legal | Import validation, intent allowlist, credential-pattern scan, resolved dependency and asset-license review | Source review passed; deeper import fuzzing and release legal review pending |

Executed outcomes are mirrored in `docs/development/test_matrix.md`; this file defines the release obligation.
