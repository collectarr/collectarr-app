# `kinds/_shared` audit

Audit date: 2026-09-05. The shared tree is an inventory for PR78; it is not
permission to keep domain behavior shared. `VISUAL STRUCTURAL` and
`TECHNICAL PRIMITIVE` are the only categories that can survive PR79, and only
when their inputs are genuinely owner-neutral.

| File | Classification | PR79 disposition |
| --- | --- | --- |
| `video/detail/video_detail_page.dart` | DOMAIN BEHAVIOR | Move into explicit library detail infrastructure |

## Audit outcome

The shared directory contains no persistence or provider implementation that
is safe to treat as universal merely because it is reused. Release projection
and source logic now live under the explicit `features/library/release`
subsystem; the only remaining candidate is the legacy video detail
implementation. PR79 has already moved TV legacy models, display models,
physical formats, episodic tracking and progress surfaces, upcoming-episode
hierarchy, TV Edit episode surfaces, Movie release shelf drilldown, generic Add
video chrome, generic detail components, catalog compatibility models, and the
owner-neutral presentation/drilldown primitives out of `_shared/video`.
Universal session history now lives under library tracking, while serial
authority persistence and UI live under explicit catalog/library subsystems.
