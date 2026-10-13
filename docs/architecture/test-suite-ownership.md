# Test suite ownership and execution

Ordinary tests mirror `lib/`. Architecture rules, contracts and shared support
are the only special categories. Integration flows live in `integration_test/`;
performance measurements live in `benchmark/` and never add skipped tests to
the correctness suite. Production code cannot depend on test support.

## Delivery stages

1. Move/rename existing tests according to production ownership, with unchanged
   assertions and fixture semantics. Rewrite relative imports and fixture paths.
2. Remove `lib/test/`, move fixtures into `test/support/`, guard the boundary.
3. Split catalog/entry/workspace/add builders and typed kind fixtures.
4. Share CSV scaffolding and app/provider/auth harnesses while retaining
   per-kind expected values.
5. Separate behavior, layout and motion assertions; remove repeated geometry
   checks and historical refactor labels.
6. Extract the Music benchmark and add an explicit artifact-producing workflow.
7. Make Core DB cleanup explicit, register strict markers and split fast/DB CI.
8. Add taxonomy checks, directory timings and informational coverage artifacts.
9. Add a small number of persistence/add/edit/offline integration flows.

Each stage gets a conventional commit with the concrete changes, reasoning

and validation. Do not turn this work into a fixture DSL or a new test framework.

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

## Current state

Release baseline verification is still underway in the App worktree.
Core DB lifecycle stage is implemented separately: pure tests no longer truncate
tables, and the fast suite is validated with PostgreSQL unavailable.
