# Persistence and Migration

Local data is stored as versioned JSON through a storage abstraction. Top-level namespaces separate settings, player progress, active session, favorites, recent games, authored levels, and migration metadata.

Writes use complete JSON values and validate before replacing the previous record. Imported backups contain a schema version, export timestamp, payload, and SHA-256 integrity digest. Unknown major schemas, invalid enum values, oversized content, duplicate authored IDs, and invalid puzzle states are rejected without changing current data.

Migrations are sequential and idempotent. Each migration has fixture tests for the oldest supported version and corrupted-input tests. No migration may silently discard a valid save; unsupported records remain untouched and produce a user-visible recovery path.
