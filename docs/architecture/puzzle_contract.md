# Puzzle Module Contract

Every enabled module provides:

- stable type ID and positive schema version;
- localized title and description keys;
- deterministic `generate(seed, difficulty)` behavior;
- JSON-safe generated and goal state;
- legal-action enumeration or validation;
- pure action application that rejects illegal input;
- solved and invariant verification;
- undo/redo compatibility through serialized snapshots;
- progressive hints with a stable identity;
- screen-reader state and action descriptions;
- score calculation based on difficulty, moves, time, and hints;
- import migration or an explicit unsupported-version error.

Generation must verify invariants before state reaches UI. A bounded generator retries deterministically and fails with a typed error instead of showing an impossible board. Puzzle-specific difficulty rules live beside each module and are tested at fixed seeds.
