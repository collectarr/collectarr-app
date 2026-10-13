# Music v1 release preparation

Requested scope: audit and integrate relevant open PRs, remove their branches
when integration/closure is verified, and promote a Music-only first release.

## Stages

1. Dependency/CI PR audit: merge changes not already covered by main; close
   obsolete updates with evidence; retain no stale PR branches after closure.
2. Activate only Music in App/Core/Sync release contracts, routing and UI.
   Unreleased modules may remain isolated in source; their tables must not be
   created, exported as active schema or migrated into this first release.
3. Preserve the exact current schema/API shapes and semantics; label this
   existing cutover as baseline v1/1.0.0. Never restore an earlier schema, API
   payload, field layout or behavior merely because its old version was v1.
   Freeze package/public contract/database version markers at v1/1.0.0.
   Dependency versions and historical Git tags are not rewritten. Do not reset
   any live database, personal data or user backup while preparing the release.
4. After the v1 baseline, all database evolution uses explicit versioned
   migrations. New kinds introduce their own tables in future migrations.
5. Add/update AGENTS.md in App, Core, Sync and the local site repository with
   ownership, strict contracts, kind scope, shared UI, privacy/data safety,
   source-based CLZ comparison, visual accents, fonts, commits and migration
   requirements. User instructions override superseded fresh-baseline rules.
6. Rewrite READMEs around Music collection features, with restrained emoji,
   screenshot placeholders and independent CLZ clean-room positioning.
7. Regenerate Core contracts, App pins and generated DB/code artifacts; update
   meaningful tests to assert the active Music release and absence of dormant
   kind tables. Run lint/analyze, architecture/schema/contracts, unit/widgets,
   native integration and Windows/Web build gates before final integration.

Do not expose a kind through a registry toggle alone while still creating its
tables. Preserve the current per-kind domain ownership for later additions.
