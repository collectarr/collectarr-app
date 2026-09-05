# `kinds/_shared` audit

Audit date: 2026-09-05. The shared tree is an inventory for PR78; it is not
permission to keep domain behavior shared. `VISUAL STRUCTURAL` and
`TECHNICAL PRIMITIVE` are the only categories that can survive PR79, and only
when their inputs are genuinely owner-neutral.

| File | Classification | PR79 disposition |
| --- | --- | --- |
| `video/detail/video_detail_page.dart` | DOMAIN BEHAVIOR | Split into movie/TV/anime detail |
| `video/release/video_release_projection_capability.dart` | DOMAIN BEHAVIOR | Move into kind release projections |
| `video/release/video_release_source.dart` | DOMAIN BEHAVIOR | Move into kind release sources |

## Audit outcome

The shared directory contains no persistence or provider implementation that
is safe to treat as universal merely because it is reused. The remaining
video candidates are concentrated in catalog mapping, release projection, and
the common video edit controller/tabs; they remain queued for the next
kind-specific de-share steps. PR79 has already moved TV legacy models,
display models, physical formats, episodic tracking and progress surfaces,
upcoming-episode hierarchy, TV Edit episode surfaces, Movie release shelf
drilldown, generic Add video chrome, generic detail components, and the
owner-neutral presentation/drilldown primitives out of `_shared/video`.
Universal session history now lives under library tracking, while serial
authority persistence and UI live under explicit catalog/library subsystems.
