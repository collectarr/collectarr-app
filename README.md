# 🎵 Collectarr Music

Your music collection, your way. Collectarr helps you organize albums, editions,
discs and tracks, with an offline-first library and optional self-hosted sync.

**Version 1 is Music only.** Other media kinds will be introduced individually
in future releases, with their own tables and explicit migrations.

## ✨ Make your collection yours

- Browse albums in covers, shelves or a spreadsheet-style list.
- Organize collections and folders; choose columns, sorting and filters.
- Edit album details, disc formats, tracks and scoped credits in one editor.
- Keep covers, personal images, links, notes and custom fields together.
- Track listening, purchases, values, locations and loans.
- Find duplicates, manage pick lists and view collection statistics.
- Import existing Music lists; export selected data or print your collection.
- Work locally, then optionally sync personal entries and publish a collection.
- Keep a consistent accent-based interface across desktop and smaller screens.

## 📸 See it in action

> **Screenshot placeholder — Music library:** cover/shelf/list views.
>
> **Screenshot placeholder — Album editor:** discs, tracks and Credits.
>
> **Screenshot placeholder — Collections:** organization, inspector and sharing.

Screenshots will use fictional demo data with no private account information.

## 🧭 Independent, familiar workflows

Collectarr is an independent **clean-room implementation inspired by CLZ Music
collection workflows**. It is not affiliated with or endorsed by CLZ and does
not bundle CLZ source code, collection data, branding, screenshots or paid font
files. Familiar behavior is implemented with Collectarr's own code and assets.

The default font is open source. An optional local font loader can use fonts
already available on your own device; proprietary fonts are not distributed.

## 🔒 Your data stays yours

The library stores personal data locally. Core provides the optional canonical
Music catalog; Sync handles personal snapshots and explicit sharing choices.
Backups and sharing remain under your control.

The current Music model is the first **v1 baseline**, not a rollback to an older
API. After this release, schema changes use ordered, data-preserving migrations.
Existing databases are never silently reset to make an update work.

## 🚀 Getting started

Download the appropriate platform build from the repository's Releases page.
Core and Sync are optional self-hosted companions:
[Core](https://github.com/collectarr/collectarr-core) ·
[Sync](https://github.com/collectarr/collectarr-sync).

<details>
<summary>Build and contribute</summary>

Use Flutter 3.47.7 and the committed lockfile:

```sh
flutter pub get --enforce-lockfile
flutter run
```

See [contributor instructions](AGENTS.md), [versioning policy](docs/versioning-policy.md)
and the [architecture status](docs/architecture/current-status.md) for technical
work. Do not publish a release until its verification gates pass.

</details>
