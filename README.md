# 🎵🎮 Collectarr

Your collection, your way. Collectarr helps you organize music, games, gaming
hardware and toys, with an offline-first library and optional self-hosted sync.

Collectarr covers **Music** and **Games**, with separate **Hardware** and
**Toys** libraries. Other media kinds will be introduced individually in future
releases, with their own tables and explicit migrations.

## ✨ Make your collection yours

- Browse albums, games, hardware and toys in covers, shelves or a
  spreadsheet-style list.
- Organize collections and folders; choose columns, column favorites, sorting
  and filters.
- Edit album details, disc formats, tracks and scoped credits in one editor.
- Track games by platform and region, with completeness, packaging, completion,
  storage and purchase details, covers and trailers.
- Keep covers, personal images, links, notes and custom fields together.
- Track listening, purchases, values, locations and loans.
- Find duplicates, manage pick lists and view collection statistics.
- Import existing Music lists and CLZ Games XML or CSV exports; export selected
  data or print your collection.
- Work locally, then optionally sync personal entries and publish a collection.
- Keep a consistent accent-based interface across desktop and smaller screens.

## 📸 See it in action

> **Screenshot placeholder — Music library:** cover/shelf/list views.
>
> **Screenshot placeholder — Album editor:** discs, tracks and Credits.
>
> **Screenshot placeholder — Games library:** platforms, covers and details.
>
> **Screenshot placeholder — Collections:** organization, inspector and sharing.

Screenshots will use fictional demo data with no private account information.

## 🧭 Independent, familiar workflows

Collectarr is an independent, fully open-source **clean-room implementation
inspired by CLZ Music and Games collection workflows**, with a stricter data
model: disc-level formats and recording data, scoped credits, fixed-type Games,
Hardware and Toys collections, partial dates and an offline-first library. It is not affiliated with or endorsed by CLZ and does
not bundle CLZ source code, collection data, branding, screenshots or paid font
files. Familiar behavior is implemented with Collectarr's own code and assets.

The default font is open source. An optional local font loader can use fonts
already available on your own device; proprietary fonts are not distributed.

Platform and service logos (PlayStation, Steam, eBay, Discogs and others) are
CC0 drawings from [Simple Icons](https://simpleicons.org), shown only to
identify a platform or service; the marks belong to their owners (see
`assets/LOGOS.md`). Platforms without such a logo use
Collectarr's own glyphs.

## 🔒 Your data stays yours

The library stores personal data locally. Core provides the optional canonical
Music and Games catalogs; Sync handles personal snapshots and explicit sharing choices.
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

Run the correctness suite with `dart run tool/run_tests.dart`.

See [contributor instructions](AGENTS.md), [versioning policy](docs/versioning-policy.md),
the [architecture status](docs/architecture/current-status.md), [testing](docs/testing.md)
and the [CLZ parity report](docs/clz-parity.md) for technical work. Do not
publish a release until its verification gates pass.

</details>
