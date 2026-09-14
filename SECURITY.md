# Security Policy

CIDP Buddy handles health data — medication names, dosages, infusion dates,
symptom notes and body weight. All of it stays on the user's device (a local
SQLite database plus user-triggered ZIP backups); the app has no backend and
sends no telemetry. That makes local data handling, backup files and the
Android/iOS permission surface the areas worth scrutinising.

## Supported versions

Only the latest release receives security fixes. Please reproduce an issue on
the newest version before reporting it.

## Reporting a vulnerability

Please **do not open a public issue** for a security problem.

Use GitHub's private vulnerability reporting instead:
[Security → Report a vulnerability](https://github.com/bmachek/CIDPbuddy/security/advisories/new).

Useful details:

- affected version and platform (Android / iOS / desktop)
- what an attacker can reach — data, files, another app's access
- steps to reproduce, ideally with a minimal case
- any logs or screenshots that help (redact real health data first)

You can expect an acknowledgement within a week. Fixes ship in the next
release; the advisory is published once the fix is out, crediting you unless
you prefer otherwise.

## Out of scope

- Attacks that require physical access to an already-unlocked device
- Issues in third-party dependencies without a demonstrated impact on this app
  (report those upstream; tell us if the app's usage makes it exploitable)
- Missing hardening that has no attack path (report it as a normal issue)
