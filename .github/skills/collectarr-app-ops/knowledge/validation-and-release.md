# Validation And Release Knowledge

## Focused validation for generic library work

Recommended focused analyze slice for generic library parity work:

```powershell
flutter analyze lib/features/library/generic/toolbar.dart lib/features/library/generic/page.dart lib/features/library/generic/body.dart lib/features/library/generic/sidebar.dart lib/features/library/generic/page_dialogs.dart lib/features/library/generic/projection.dart lib/features/library/generic/toolbar_chrome.dart
```

Recent focused widget test for alphabet row changes:

```powershell
flutter test test/features/library/generic/library_toolbar_test.dart
```

When touching DB schema:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

## Known test behavior

- Generic library widget tests may use plain `MaterialApp`; route updates must guard `GoRouter` access with `GoRouter.maybeOf(context)`.
- Tight toolbar layout assertions may need small tolerance updates when the visible control set changes.
- On Windows, a stuck `sqlite3.dll` test race can require killing `dart` processes and cleaning `build/` plus `.dart_tool/`.

## collectarr-app alpha release notes style

Use the current house style:
- `## What's Changed`
- 2-3 summary bullets
- emoji section headers like `### ✨ Features`, `### 🐛 Fixes`, `### 🧰 CI & Build`, `### 🧪 Quality`
- `Full Changelog:` link at the end

Typical release-note workflow:
1. Inspect the previous release notes.
2. Inspect the commit or PR range between tags.
3. Group shipped changes into user-facing buckets.
4. Update the GitHub release body.

## Repo-specific release caveat

The current `main` release automation is not aligned with continuing the alpha series automatically. If the user asks for another alpha release, verify the planned version first instead of assuming `release.yml` is safe to run as-is.
