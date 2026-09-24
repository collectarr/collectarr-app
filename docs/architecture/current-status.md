# Current architecture status

Authoritative status for the typed library boundary. Historical audit files
remain design history; this document describes the current implementation.

Active work is tracked in the [kind boundary plan](kind-boundary-completion-plan.md),
the [Add/Edit form plan](add-edit-form-unification-plan.md), and the
[UI readability plan](ui-readability-plan.md). This document
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

Each kind registers independent work, release, and copy workspace registries.
Fields, columns, sorts, groups, and defaults are materialized from explicit
entity scopes; an invalid scope fails instead of being rebound. Edit UI owns
shell/controller lifecycle only; kind semantics are implemented by the split
work/release/copy edit-session contracts and kind-owned mutation payloads.

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

Add and Edit still duplicate field definitions and UI state in several kinds.
For example, Movie has a controller-backed manual Add draft, an immutable Add
draft, and separate Edit drafts. The shared `LibraryFieldSpec` contract exists,
but the manual Add panes are still built separately. The first Add/Edit task is
to make manual Add submit an actual command from its entered values for each
kind. Currently only Music registers a `manualCandidateBuilder`; the fallback
can call `submitCurrentSelection()` without a selection and report success.

The generic Add/provider controller still handles several search, hydration,
selection, and submit concerns. All nine kinds now have explicit manual
candidate builders, and manual Add no longer closes after a no-op. Seven kinds
still have separate controller-backed Add and Edit field definitions; the
typed shared values and kind-owned create/update adapters are being migrated
from Movie outward. Other cross-kind surfaces need focused review before the
boundary plan can close.

## Verification

The current Add/Edit change batch has a successful targeted analyzer pass and
Windows debug build. Whole-repository analysis reports lint warnings and infos;
tests were not run. Historical counts in older audit files do not certify the
current working tree.

## External Core dependency

Core exposes canonical release layers for Comic Issue -> Variant, Manga Volume
Work -> Edition, and Anime Work -> Release -> Media with episode coverage. App
mappings consume those Core-owned identifiers and keep work-only payloads
release-less; they do not fabricate release identities when Core has no
canonical release.
