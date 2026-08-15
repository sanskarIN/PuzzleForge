# Architecture

PuzzleForge uses a layered, feature-oriented Flutter architecture:

```text
UI screens and reusable widgets
        ↓
App state and gameplay session controllers
        ↓
Puzzle modules and domain services
        ↓
Versioned local persistence and platform adapters
```

Puzzle rules are independent of widgets. A module receives a deterministic seed and difficulty, returns serializable state, validates actions, supplies hints and accessibility descriptions, and verifies solved state. Controllers own undo/redo, elapsed time, hint charging, saves, and completion events. Storage and external-link behavior are injected behind services so tests do not need platform plugins.

No backend is included in the initial release. Any future competitive service must be server-authoritative and threat-modelled separately.
