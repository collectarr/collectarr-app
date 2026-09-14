# `kinds/_shared` audit

Audit date: 2026-09-05. The shared tree is an inventory for PR78; it is not
permission to keep domain behavior shared. `VISUAL STRUCTURAL` and
`TECHNICAL PRIMITIVE` are the only categories that can survive PR79, and only
when their inputs are genuinely owner-neutral.

| File | Classification | PR79 disposition |
| --- | --- | --- |
| _No files remain_ | — | — |

## Audit outcome

The shared directory is now empty. Release projection/source logic and the
legacy video detail implementation live under explicit library detail/release
subsystems rather than inside a kind-shared tree. PR79 has moved TV legacy
models, display models, physical formats, episodic tracking and progress
surfaces, upcoming-episode hierarchy, TV Edit episode surfaces, Movie release
shelf drilldown, generic Add video chrome, generic detail components, catalog
compatibility models, and the owner-neutral presentation/drilldown primitives
out of `_shared/video`.
Universal session history now lives under library tracking, while serial
authority persistence and UI live under explicit catalog/library subsystems.
