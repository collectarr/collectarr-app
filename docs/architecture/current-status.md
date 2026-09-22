# Current architecture status

Authoritative status for the typed library boundary. Historical audit files
remain design history; this document describes the current implementation.

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

## Verification

Analyzer and full test verification are intentionally deferred until the
current code migration batch is complete. The last recorded baseline was:

```text
flutter analyze --no-pub  -> No issues found
flutter test --no-pub     -> 2002 passed, 10 skipped
```

## External Core dependency

Core exposes canonical release layers for Comic Issue -> Variant, Manga Volume
Work -> Edition, and Anime Work -> Release -> Media with episode coverage. App
mappings consume those Core-owned identifiers and keep work-only payloads
release-less; they do not fabricate release identities when Core has no
canonical release.
