# Threat Model

## Assets

Valid saves, honest local progress, safe imported content, signing identity, player privacy, and application availability.

## Trust boundaries

- External backup/authored-level JSON entering validated parsers
- App-to-browser and app-to-mail intents
- Android backup/restore into local storage
- Build environment and signing secrets
- Future network or billing adapters, which are currently absent

## Principal threats and controls

| Threat | Control |
|---|---|
| Malformed or oversized import | Size limit, strict schema/type/range validation, verify before replace |
| Progress duplication | Stable completion IDs and idempotent award processing |
| Hint double charge | Stable hint IDs and atomic delivery/debit record |
| Intent injection | Fixed HTTPS/mailto allowlist and external launch adapter |
| Save corruption | Versioned envelope, checksum for exports, default recovery without overwrite |
| Secret exposure | No secrets in source; environment/repository secrets for release tooling |
| Dependency compromise | Lockfile, automated audit, minimal dependency surface, reviewed upgrades |
| Debug tool abuse | Hidden unlock, production-safe diagnostics, no secret/entitlement access |

Local scores are not cheat-resistant and must never be accepted as authoritative in a future competitive service.
