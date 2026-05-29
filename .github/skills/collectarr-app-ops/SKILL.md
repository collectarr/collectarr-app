---
name: collectarr-app-ops
description: "Use when working on collectarr-app recurring workflows: restart or run the Flutter web preview on port 7361 for the VS Code browser sandbox, validate generic library UI or CLZ parity changes with focused Flutter tests/analyze, draft or refresh alpha release notes for collectarr-app, or avoid common repo-specific mistakes like running flutter from the parent folder instead of collectarr-app."
---

# collectarr-app ops

Use this skill for the repetitive `collectarr-app` workflows that come up during UI parity work and browser-driven validation.

## Scope

This skill is for:
- running or restarting the Flutter web preview used by the Copilot sandbox browser
- validating focused changes in `lib/features/library/**`
- drafting or refreshing structured alpha release notes in the repo's current style
- avoiding repo-specific footguns that already happened in this workspace

This skill is not for:
- backend work in `collectarr-core`
- full project setup or scaffolding
- broad release automation changes across multiple repos

## Assets

Read these first when the task matches:
- `knowledge/browser-preview.md`
- `knowledge/validation-and-release.md`

## Workflow

### 1. Browser preview

If the user asks to open, run, preview, reload, or verify the web UI:
- prefer the VS Code sandbox browser
- use the existing shared page when possible
- ensure the local server is actually listening before trying browser actions

Canonical launch command from the project root:

```powershell
Set-Location c:\Users\andrvoicu\Desktop\repos\collectarr-app
.\scripts\run_web_for_copilot.ps1 -Port 7361 -Device chrome -Route /libraries?kind=manga -NoOpen
```

If you run `flutter run` manually, run it from `collectarr-app`, not from the parent `repos` folder.

After restart:
- verify port `7361` is listening
- reload the existing browser page
- if the page shows only `Enable accessibility`, that still means Flutter is live

### 2. Focused validation for library UI work

For changes in `lib/features/library/generic/**` or nearby workspace widgets:
- prefer the cheapest touched-slice validation first
- use focused `flutter test` for the exact touched widget/test file before widening scope
- use focused `flutter analyze` on touched files before full analyze

Common fast checks are listed in `knowledge/validation-and-release.md`.

### 3. Release notes

For alpha release notes on `collectarr-app`:
- inspect the previous release notes and recent PR/commit range first
- keep the current style: short summary bullets, emoji section headers, then `Full Changelog`
- prefer updating release notes with accurate shipped content, not guesses

### 4. Known mistakes to avoid

- Do not run `flutter run` from `c:\Users\andrvoicu\Desktop\repos`; it fails with `No pubspec.yaml file found`.
- When browser reload fails, check the local server first before assuming the page tooling is broken.
- Generic-library widget tests may run under plain `MaterialApp`, so route-sync logic must tolerate missing `GoRouter`.
- After schema changes, regenerate Drift code.
