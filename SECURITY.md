# Security Policy

## Supported versions

Security fixes are provided for the latest released minor version. Development builds are unsupported and must not be used to protect high-value data.

## Reporting a vulnerability

Do not open a public issue for an exploitable vulnerability. Email `supportramsandesh@gmail.com` with the affected version, reproduction steps, impact, and any suggested mitigation. Do not include real user data or credentials. You should receive an acknowledgement within seven calendar days, but this is a best-effort open-source target rather than a service-level agreement.

## Scope

Relevant reports include unsafe import parsing, path or intent injection, sensitive logging, backup integrity bypass, dependency compromise, insecure URL handling, entitlement bypass if monetization is later enabled, and online authority failures if network features are added.

Never commit signing keys, API tokens, service credentials, `.env` production files, or private reports. See `docs/security/threat_model.md` for design assumptions.
