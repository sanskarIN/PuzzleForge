# Release Test Matrix

| Layer | Required evidence | Owner/state |
|---|---|---|
| Pure domain | Generator determinism, invariants, rules, solver/verifier, scoring | Automated; passed in 55-test suite on 24 October 2026 |
| Session | Undo/redo, replay, timer, hint idempotency, serialization | Automated; passed |
| Persistence | Round trip, corruption, import size/checksum, write ordering | Current schema/checksum and three gated-I/O races pass; multi-version migrations and cross-record rollback are not implemented |
| Localization | English/Hindi key parity, fallback, plurals, pseudolocale, long text | Automated catalog tests passed; manual linguistic/large-text device review pending |
| Widgets | Home, navigation, boards, creator/support links, settings, semantics | Automated smoke/semantics, clipboard fallback, Hindi large-text support, and restored Continue-to-result pass |
| Integration | Startup, complete/save/resume, daily, backup | Android journey authored; device execution pending |
| Accessibility | TalkBack, large text, contrast, reduced motion, targets | Manual physical/emulator; pending |
| Android | Debug APK, signed AAB, background/resume, orientations | See dated artifact register; signed upload and device checks pending; foreground pause/resume passes widget coverage |
| Performance | Frame timing, generator bounds, memory pressure | Profile build/device; pending |
| Security/legal | Import validation, intent allowlist, credential-pattern scan, resolved dependency and asset-license review | Source review passed; deeper import fuzzing and release legal review pending |

Executed outcomes are mirrored in `docs/development/test_matrix.md`; this file defines the release obligation.
