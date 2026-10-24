# Persistence and Migration

The current app stores three versioned JSON records through KeyValueStore: settings, player progress, and active session. Favorites, achievements, and recent completion history are contained in player progress. Only schema version 1 is supported; no multi-version migration engine is implemented yet.

AppController serializes writes, imports, session removal, and full deletion through one recoverable queue. Progress/session snapshots are captured before asynchronous writes, and completion records are captured when the solving move occurs. A later replay cannot modify a completion already queued for persistence. persistSession() waits for earlier writes even when no playable session remains.

Each record is size checked and written as a complete JSON string. The three records are not a transactional database: a device failure during a multi-record import can leave a partial update. Validation rejects invalid backups before scheduling writes, but does not provide cross-record rollback after storage failure.

Backups contain a format identifier, schema version, timestamp, payload, and SHA-256 digest. The digest detects accidental modification; it does not authenticate against a person who can recompute it. Unsupported schemas, oversized payloads, malformed settings/progress, and invalid session states are rejected. Corrupt stored records are retained while safe defaults and a recovery notice are shown.

Puzzle Path retains puzzleforge. preference keys and the puzzleforge-backup envelope so the display-name change does not discard existing data. Before changing either schema, implement explicit migrations and fixtures for supported older records.
