# Current architecture status

Authoritative status for the typed library boundary. Historical audit files
remain design history; this document describes the current implementation.

Active work is tracked in the [kind boundary plan](kind-boundary-completion-plan.md),
the [Add/Edit form plan](add-edit-form-unification-plan.md), the
[all-kind schema reorganization plan](kind-schema-reorganization-plan.md), and
the [UI readability plan](ui-readability-plan.md). This document
does not treat an old audit checkpoint as verification of the current working tree.

## Entity contract

Every library kind is addressed structurally as:

```text
Work -> Release -> Copy
```

The shared contracts use only `LibraryEntityScope.work`, `.release`, and
`.copy`. Browser and editor behavior lives in separate policies.

Entity references carry the complete parent chain. A copy reference therefore
cannot be constructed without its work and release identity.

## Workspace and edit boundaries

Each kind registers independent work, release, and copy workspace registries
from an explicit kind-owned schema. Fields, columns, sorts, groups, and defaults
live beside the schema for their scope; there is no aggregate field catalog or
runtime `forScope` filter. Edit UI owns shell/controller lifecycle only; kind
semantics are implemented by split work/release/copy edit-session contracts
and kind-owned mutation payloads.

Music additionally has dedicated Release Group and Release editors. Owned
Copies and Listening are release-level contributors, not fields on the Music
Release Group aggregate.

## Provider boundary

Provider adapters expose structural search records and normalized raw envelopes.
Kind mappers decode provider attributes into kind-owned candidates/models. The
shared search record does not expose Book, Comic, Music, or other kind-specific
fields as public members. Preview chrome is common, while series, publishing,
video and game details are assembled by the selected kind mapper.

Music uses its typed provider capability directly and does not use the erased
provider metadata envelope. MusicBrainz protocol DTOs remain in the provider
adapter; Music candidate mapping is owned by the Music integration.

## Remaining implementation work

All nine kinds provide manual candidate builders and typed catalog Add plus
dedicated Edit forms. Each kind's Add and Edit schemas share the same
kind-owned, scope-specific field specifications and typed form values. Workspace
schemas are explicit for Work, Release, and Copy across all nine kinds; Music
keeps Release Group, Release, and Owned Copy as separate workspace scopes.

The older combined Core-candidate edit shell remains active for Core correction
proposals and for its existing links, images, relations, and personal/tracking
panels. Its kind-owned edit sessions edit `CatalogSearchCandidate` transport
values, while dedicated forms edit persisted kind domain entities. The two paths
have different write targets, so their similarly labeled fields are not shared
through a second typed-field alias.

The generic Add/provider controller still handles search, hydration, selection,
and submit concerns. Other cross-kind surfaces need focused review before the
boundary plan can close.

## Verification

Add/Edit schema contracts for all nine kinds and both schema-renderer suites pass
(93 tests). Targeted analysis of the changed form schemas, renderers, and tests
reports no issues, and the Windows debug build succeeds. Whole-repository
analysis has no errors; it reports existing warning and info diagnostics
elsewhere. Historical counts in older audit files do not certify the current
working tree.

## External Core dependency

Core exposes canonical release layers for Comic Issue -> Variant, Manga Volume
Work -> Edition, and Anime Work -> Release -> Media with episode coverage. App
mappings consume those Core-owned identifiers and keep work-only payloads
release-less; they do not fabricate release identities when Core has no
canonical release.
