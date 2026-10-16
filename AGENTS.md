# Working rules

- Follow the user's instructions over this file.
- Use conventional commit titles. For real changes, add a body: what changed,
  why, and how it was checked. Do not use one-line commits for whole stages.
- Keep each commit to one fix, feature, refactor or docs change; split mixed
  work into separate commits instead of one commit per session.
- Update `CHANGELOG.md` under "Unreleased" in the same commit: one short,
  user-facing line in the matching section (Features, Fixes, Refactors, Docs,
  CI & Build), describing the effect rather than files or internals. The
  Release workflow turns these entries into the release notes.
- Run `dart run tool/ci_check.dart` before pushing; it runs the same checks as
  CI (add `--integration` for the native flows).
- Merge pull requests with several commits using "Rebase and merge", so each
  conventional commit reaches `main` and sets the next version; squash only
  single-change pull requests.
- Release by running the Release workflow on `main`
  (`docs/versioning-policy.md`); do not bump versions or tag by hand.
- No legacy support, compatibility layers, deprecated aliases or dead code.
- After the initial Music baseline, change schemas with explicit ordered
  migrations. Never reset a database to make an upgrade work.
- Never modify live databases or backups. Use isolated test storage.
- Do not rewrite history or replace published tags without an explicit request.
- CLZ is a reference only. Do not copy its code, paid fonts or proprietary assets.
  Inspect it read-only: open editors and dialogs, then Cancel; never save there.
- The goal is an improved, fully FOSS CLZ. Match its workflows and density, but
  keep the stronger model listed under "Deliberate improvements" in
  `docs/clz-parity.md`.
- Compare UI with the workflow in `docs/clz-parity.md` and record results there:
  move fixed items, add or close open ones. Do not add dated audit, plan or QA
  files; update the living doc for the topic and delete superseded docs.
- Scripts and tools must never delete, reset or seed the user's real database.
- Keep scratch files, logs and captures out of the repository; use a temporary
  directory.
- Keep kind logic in kind folders. Share UI mechanics, not kind rules.
- Use kind accents for library identity. Use shared blue for utility actions,
  input focus/carets, item/folder selection, settings labels and links.
  Collection status colors are fixed, independent of kind.
- Do not bundle Gilroy. Load only fonts supplied locally by the user.
- Run correctness tests with `dart run tool/run_tests.dart`. Disabling kind
  tests must keep shared correctness, contracts and architecture checks active.
