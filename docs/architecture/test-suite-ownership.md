# Test suite ownership and execution

Ordinary tests mirror `lib/`. Architecture rules, contracts and shared support
are the only special categories. Integration flows live in `integration_test/`;
performance measurements live in `benchmark/` and never add skipped tests to
the correctness suite. Production code cannot depend on test support.

## Implemented ownership

Tests now follow production locations, with no root stray tests or `lib/test/`.
Small catalog, entry, workspace, add and tracking builders live in support;
entry details require an explicit matching kind. Book/Anime CSV expectations
share scaffolding while remaining owned by their kind. Auth/provider/app setup
is shared by widget and native flows.

Drawer navigation is independent of its motion contract, and shared partial-date
separator geometry has one layout test. The Music benchmark lives outside normal
correctness discovery and writes a manual/weekly artifact. Architecture rules and
taxonomy checks run through the shared checker; removed runtime abstractions are
an AST ownership rule, not a historical cleanup proof scanner.

CI publishes informational coverage and file/directory timings. Native flows
exercise navigation, Core add and personal SQLite persistence/reload against
isolated databases. Core's explicit fast/DB split avoids database work in pure
tests and publishes separate coverage reports.

## Kind selection

Default correctness execution uses the released kind set. A runner can select
source-owned kind tests explicitly, including future kinds, or exclude them.
Shared correctness, contracts and architecture checks always run. Explicit
selection validates names and reports selected/excluded files; no silent skips
or blanket suppression of failing tests. Mixed tests are split by ownership
before kind selection can reliably exclude a kind.

An inactive kind does not remove its source from architecture ownership checks.
Source tests which exercise isolated kind semantics may run without registering
the kind publicly. Tests requiring that kind's DB tables need an explicit
isolated fixture; they cannot rely on the Music-only release database.

## Verified release selection

On 2026-10-13 the App release selection passed 903 correctness tests with zero
failures/skips, generated coverage, and passed all four Windows native cases.
The selector included 252 files and excluded 19 inactive kind files. Explicitly
requesting unreleased kinds still requires suitable source/persistence fixtures;
this result does not claim future-kind tables exist in the release database.

Core passed 116 tests with PostgreSQL unavailable and 51 database tests against
an isolated local test database. Both coverage artifacts were generated. App
benchmark measurements for 1k/5k Music albums passed separately and never enter
the correctness test count.

This cleanup is complete; extend the existing small fixtures and harnesses for
real consumers rather than adding a test framework or speculative abstractions.
