# Working rules

- Follow the user's instructions over this file.
- Use conventional commit titles. For real changes, add a body: what changed,
  why, and how it was checked. Do not use one-line commits for whole stages.
- No legacy support, compatibility layers, deprecated aliases or dead code.
- After the initial Music baseline, change schemas with explicit ordered
  migrations. Never reset a database to make an upgrade work.
- Never modify live databases or backups. Use isolated test storage.
- Do not rewrite history or replace published tags without an explicit request.
- CLZ is a reference only. Do not copy its code, paid fonts or proprietary assets.
- Keep kind logic in kind folders. Share UI mechanics, not kind rules.
- Use kind accents for library identity. Use shared blue for utility actions,
  input focus/carets, item/folder selection, settings labels and links.
  Collection status colors are fixed, independent of kind.
- Do not bundle Gilroy. Load only fonts supplied locally by the user.
- Run correctness tests with `dart run tool/run_tests.dart`. Disabling kind
  tests must keep shared correctness, contracts and architecture checks active.
