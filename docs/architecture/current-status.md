# Current architecture status

Authoritative status for the typed library boundary. Historical audit files
remain useful as design history, but this document describes the current
implementation.

## Entity contract

Every library kind is addressed structurally as:

```text
Work -> Release -> Copy
```

The shared contracts use only `LibraryEntityScope.work`, `.release`, and
`.copy`. Topology contains structural descriptors; browser and editor behavior
lives in separate policies.

Entity references carry the complete parent chain. A copy reference therefore
cannot be constructed without its work and release identity.

## Workspace and edit boundaries

Each kind registers independent work, release, and copy workspace registries.
Fields, columns, sorts, groups, and defaults are materialized from explicit
entity scopes. Edit UI owns shell/controller lifecycle only; kind semantics are
implemented by `LibraryKindEditSession` and kind-owned mutation payloads.

Music additionally has dedicated Release Group and Release editors. Owned
Copies and Listening are release-level contributors, not fields on the Music
Release Group aggregate.

## Provider boundary

Provider adapters expose structural search records and normalized raw envelopes.
Kind mappers decode provider attributes into kind-owned candidates/models. The
shared search record does not expose Book, Comic, Music, or other kind-specific
fields as public members.

Music uses its typed provider capability directly and does not use the erased
provider metadata envelope.

## Verification

The last complete verification on the typed entity-boundary commit was:

```text
flutter analyze --no-pub  -> No issues found
flutter test --no-pub     -> 2002 passed, 10 skipped
```

## External Core dependency

Core now exposes canonical release layers for these kinds: Comic Issue →
Variant, Manga Volume Work → Edition, and Anime Work → Release → Media with
episode coverage. App mappings consume those Core-owned identifiers and keep
work-only payloads release-less; they do not fabricate release identities when
Core has no canonical release.
