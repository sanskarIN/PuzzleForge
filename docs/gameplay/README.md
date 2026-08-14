# Gameplay

Every session is created from a puzzle ID, schema version, seed, difficulty, and mode. Actions are validated by the module before a new immutable snapshot is accepted. The session controller manages undo/redo, timing, pause, hint delivery, persistence, replay, and completion.

Enabled module rulebooks and difficulty formulas live beside their implementation. Daily seeds use `UTC date + puzzle ID + generator version`, hashed to a stable positive integer. Custom seeds are normalized and bounded. A changed generator requires a version bump so an older date continues to reproduce its recorded board.
