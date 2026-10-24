# Known Issues

Reviewed 24 October 2026.

| ID | State | Description / next action |
|---|---|---|
| TOOL-001 | Resolved | GitHub CLI and connected tools work; branches and review PRs are published. |
| DATA-001 | Resolved | Queued saves recreated deleted data and rapid settings writes finished out of order. One queue and snapshots pass gated-I/O regressions. |
| DATA-002 | Resolved | Immediate replay modified an in-flight completion. Capture the record on the solving event. |
| LIFE-001 | Resolved in automated tests | Continue and foreground recovery pass widget tests; Android device validation remains open. |
| QA-002 | Open | No connected Android device. Run integration, TalkBack, large text, lifecycle, orientation, low-memory, and profile checks. |
| REL-001 | Open | No maintainer upload key is available. Configure ignored android/key.properties, require signing, and verify the AAB against Play Console. |
| FEAT-001 | Open | Audio/music/haptics/notification services are absent; controls persist preferences only. |
| FEAT-002 | Open | Campaign selection has no authored content/milestone locks; mastery and missions are unfinished. |
| DATA-003 | Open | Only schema 1 is supported. Multi-version migrations and cross-record import rollback are not implemented. |
| BUILD-002 | Follow-up | AGP 9 reports deprecated legacy Kotlin/DSL flags and SDK XML warnings. Verify builds before a separate plugin migration. |
