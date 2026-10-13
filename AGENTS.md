# Collectarr contributor instructions

## Product and release scope

- The first public release is Music only. Keep the current Music schema, API,
  canonical payloads and behavior intact; marking them v1 is a version reset,
  never a rollback to a historical v1 implementation.
- Packages/public baseline markers start at 1.0.0/v1. Do not reset dependency
  versions, rewrite Git history or delete historical release tags implicitly.
- Unreleased kinds may remain isolated in source for future development. They
  must not appear in release UI/API/contracts or create database tables.
- New kinds are added deliberately with their own schema/tables and migrations;
  do not pre-create eight dormant kinds in the first release database.

## Ownership and implementation

- Core owns canonical catalog data. App owns personal library entries, notes,
  purchases/sales, loans, locations, listening data and custom field values.
  Sync synchronizes personal snapshots and sharing; it is not a catalog service.
- Keep kind semantics in kind modules/capabilities. Shared code renders or
  orchestrates contributions. Avoid central kind switches and duplicated
  field/export/search/filter/sort capability flags.
- Field metadata owns id, label, type, one/many cardinality, source/path,
  capabilities and vocabulary. Many-valued grouping/filtering uses contained
  values; scalar sorts require explicit reducers with deterministic date rules.
- Music edition metadata stays at album scope; physical/recording metadata,
  technical capabilities and tracks belong to discs. Credits have stable IDs,
  optional real contributor references, role vocabulary and instrument lists.
- Derived workspace facts are immutable, deduplicated and non-persistent.
  Build once per projection; never traverse discs in sorting comparators.
- Canonical APIs validate strict typed payloads and reject obsolete fields.
  Import normalization belongs to import workflows, never hidden API repairs.
- No legacy compatibility layers, deprecated aliases, speculative abstractions,
  dead helpers or DTO fallbacks. Remove confirmed unused code completely.

## Persistence and migrations

- Fresh installations start at schema baseline 1 using the current Music
  structure. Existing development databases remain untouched and must never
  be opened through a lower-version baseline connection.
- The current Music implementation is frozen as the initial v1 baseline.
  After release, every persistent schema change requires an explicit ordered
  migration. Do not reset databases, replace schemas with fresh bases or drop
  personal data to make an upgrade work.
- Keep migration versions monotonic after the v1 freeze. Adding a kind requires
  a migration creating its tables; changing existing tables requires a tested
  data-preserving migration. Test upgrades from supported prior schemas and
  fresh installation of the current schema.
- Never reset, migrate or rewrite a live database or backup during development
  without the user's explicit authorization. Use isolated test databases.

## UI and reference comparisons

- Collectarr is implemented independently as a clean-room recreation inspired
  by familiar CLZ workflows. Do not copy proprietary implementation code,
  datasets, artwork, paid font/icon files or brand assets into repositories.
  Do not claim CLZ affiliation, endorsement or official compatibility.
- Verify visual/behavior changes with the real application and reference
  screenshots/computed styles where available. Compare geometry, alignment,
  fonts/weights, icons, panels, hover/cursors, menus, resize and animation.
- Preserve Collectarr kind accents rather than CLZ blue selection highlights.
  Use semantic AppIcons and shared palette/geometry/control primitives.
- Keep all normal field controls aligned and equally tall; caret and active
  colors come from the current kind. Menus are anchored overlays with hover
  and pointer cursors. Share inspector renderers across side/fullscreen views.
- Do not bundle Gilroy. Use the open-source fallback and the existing optional
  local font loader. CLZ normal 400 corresponds to Gilroy Medium, not Regular.

## Work and verification

- Work autonomously within the user's authorized scope. User instructions
  override these guidelines, including the old pre-release fresh-base policy.
- Preserve concurrent user changes and running applications. Prefer isolated
  worktrees for integration/release work. Never force-push main or reintroduce
  rejected cutover changes through a careless merge.
- Use conventional semantic-release commit titles and substantial bodies:
  concrete change, reason, behavior, validation and relevant limitations.
- Review remaining PRs against current main. Merge relevant updates only after
  meaningful checks; close already-covered updates and remove their branches
  after integration/closure. Preserve archived stage history when needed.
- Regenerate contracts/pins and DB/code artifacts from their source. Require
  clean generator checks, lint/analyze, architecture/contracts, relevant tests,
  native integration and platform builds before release. Fix CI failures.
- Keep README feature-oriented with restrained emoji, real capabilities,
  screenshot placeholders and clear independent CLZ clean-room positioning.
  Put detailed deployment/architecture instructions in linked documentation.

## App checks

Use Flutter 3.47.7 and the locked dependency set. Keep hashed contract files at
LF. Regenerate Drift and kind artifacts, verify pinned contracts, run format,
analyze, architecture checks, unit/widget tests, native integration smoke and
Windows/Web builds. Keep native tests on isolated in-memory databases.
