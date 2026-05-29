---
description: "Use when working on collectarr-app recurring operations: restarting or reloading the Flutter web preview in the VS Code sandbox browser, validating generic library or CLZ parity changes, or drafting alpha release notes. Before acting, load the `collectarr-app-ops` skill from `.github/skills/collectarr-app-ops/` and follow its verified commands and gotchas."
---

# collectarr-app ops routing

When the task is one of these recurring workflows:
- browser preview / restart / reload / sandbox verification
- focused validation for `lib/features/library/**`
- alpha release notes for `collectarr-app`

Do not improvise the command sequence.

First load and follow:
- `.github/skills/collectarr-app-ops/SKILL.md`

Key reasons:
- the canonical web preview flow in this repo uses port `7361`
- running `flutter run` from the parent `repos` folder is a known mistake
- focused validation commands and release-note style are already captured there
