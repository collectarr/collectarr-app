# Catalog Item v1 Kind Coverage

This document replaces the earlier Work/Release capability matrix. The active
library routes for Anime, Board Game, Book, Comic, Game, Manga, Movie, Music,
and TV use one Catalog Item workspace and App-owned Owned Copies.

| Kind | Catalog Item v1 details | Repeated data contained by the item | CLZ field ledger |
| --- | --- | --- | --- |
| Anime | `AnimeCatalogDetailsV1` | Episodes and credits | Provisional |
| Board Game | `BoardGameCatalogDetailsV1` | Components and related items | Provisional |
| Book | `BookCatalogDetailsV1` | Contributors and series membership | Provisional |
| Comic | `ComicCatalogDetailsV1` | Creators, characters, and story arcs | Provisional |
| Game | `GameCatalogDetailsV1` | Related items | Provisional |
| Manga | `MangaCatalogDetailsV1` | Chapters and contributors | Provisional |
| Movie | `MovieCatalogDetailsV1` | Media tracks and credits | Provisional |
| Music | `MusicCatalogDetailsV1` | Discs, tracks, credits, and links | Based on one saved CLZ Music album page |
| TV | `TVCatalogDetailsV1` | Seasons and episodes | Provisional |

The shared Catalog Item API and workspace are active for all nine kinds.
Owned Copies are stored in a separate App table and refer directly to a
Catalog Item. Add can select or create a catalog item and then create a copy;
edit separates catalog details from copy details.

This is an architecture and coverage summary, not a claim of full data
migration. The previous Drift Work/Release tables, providers, and legacy
transport code still exist while the coordinated v1 reset is completed. Only
the Music field ledger currently has a saved CLZ form source. The other eight
ledgers remain provisional until their reference forms and fields are agreed.
