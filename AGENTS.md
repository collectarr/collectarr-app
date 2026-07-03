# Collectarr App — Codex Instructions

## Product boundary
collectarr-app is the local-first Flutter client. It owns local storage, shelf UX, collection state, personal tracking, owned/wishlist data, custom fields, inspector/edit UI, import/export, and presentation.

collectarr-core owns canonical catalog metadata, provider integrations, ingest, admin metadata services, and contract exports.

Do not move app-owned personal data into Core DTOs.

## Core contract sync
The app imports Core contracts from tool/core_contracts/:
- openapi.json
- metadata-field-schema.json
- active-kinds.json
- provider-support.json
- contract-manifest.json

These should come from ../collectarr-core/contracts via tool/update_core_contracts.ps1.

Do not manually write active kinds or provider support JSON in the app. Core is the source of truth.

## DTO architecture
Generated Core DTOs are transport-only.

Correct flow:
Core generated DTO
-> App domain model
-> Personal/local overlay
-> WorkspaceEntry / InspectorViewModel / EditViewModel
-> UI

Do not use generated DTOs directly inside widgets.

Do not map typed DTOs back to CatalogItem as the final model for new kind-first features.

CatalogItem is legacy/projection compatibility only.

## Personal data model
App-owned personal data includes:
- OwnedItem
- WishlistItem
- TrackingEntry
- ReadingQueueEntry
- Loan
- personal notes
- location/storage
- purchase/sale data
- custom field definitions and values

CatalogEntityRef is the semantic catalog target.
itemId is legacy/projection/local compatibility.

Prefer:
- catalogRef = canonical target
- itemId = fallback/projection anchor

Metadata refresh from Core must not delete or overwrite personal data.

## Custom fields
Custom fields must support target scopes:
- work
- edition
- release
- issue
- episode
- track
- media
- ownedCopy
- trackingEntry

Persist custom field values by:
- targetId
- targetScope
- catalogRef
not only ownedItemId.

## Kind-first UI
Book should be the reference implementation.

Target flow:
BookWorkDto / BookEditionDto
-> BookWork / BookEdition app domain
-> personal overlay
-> BookWorkspaceEntry
-> BookInspectorViewModel
-> BookEditViewModel

Repeat the pattern for Game and BoardGame after Book.

## GenericLibraryPage
GenericLibraryPage should become shell + wiring only.

Move behavior into:
- kind browser delegates
- projection providers
- search controllers
- selection controllers
- toolbar presenters
- custom field providers

Kind delegates own navigation semantics:
- Book: work -> edition
- Game: work -> release/platform
- BoardGame: work -> edition
- Movie: work -> release
- TV: series -> season -> episode
- Music: release -> media -> track
- Comic: work/series -> issue
- Manga: work -> volume/chapter
- Anime: series -> episode

## API usage
Prefer typed Core routes.

Do not add new feature code using:
- /metadata/{kind}/{id}
- /metadata/items/...
unless the code is explicitly marked legacy compatibility.

## Local checks
After changes, run relevant checks:
- ./tool/update_core_contracts.ps1
- dart run build_runner build --delete-conflicting-outputs
- flutter analyze
- flutter test

If a check cannot be run, state why.
