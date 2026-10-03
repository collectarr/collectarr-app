# Collectarr Kind Field Ownership & Scope Classification

This document classifies fields across the nine active Collectarr kinds as **Catalog Item metadata**, **Personal data**, or **Derived / Session data**. Each collectible edition, version, issue, or release is one Catalog Item. Personal values belong to that same local entry, but remain separate from canonical metadata so they never cross the Core boundary.

The labels below describe field ownership only. They do not imply separate editable Work, Release, or Copy records. Music is grounded in the saved CLZ Music form; exact CLZ field parity for the other eight kinds remains unverified until their Edit-form captures are reviewed.

---

## Ownership Definitions

1. **Catalog Item Metadata**
   - Canonical facts about one concrete collectible edition, version, issue, or release.
   - *Examples*: Title, creators, publisher, release date, format, identifiers, contained tracks or episodes, genres, and other kind-specific details.

2. **Personal Data**
   - Values specific to a user's local entry, separate from Core's canonical catalog document.
   - *Examples*: Condition, grade, price paid, purchase date, storage location, signed-by notes, entry completeness, and user-entered valuation snapshots.

3. **Derived / Session**
   - Runtime calculated or aggregated statistics from session tracking (reading, listening, watching, playing).
   - *Examples*: Play count, last played, listen count, last listened, watch progress, session history.

---

## Kind-by-Kind Ownership Matrix

### 1. Comic
| Field | Scope | Description |
|---|---|---|
| `title`, `series`, `issueNumber` | Catalog Item Metadata | Canonical series and issue identification |
| `writers`, `artists`, `coverArtists` | Catalog Item Metadata | Issue creative contributors |
| `characters`, `storyArcs` | Catalog Item Metadata | Canonical comic universe entities |
| `keyEvents` (`ComicKeyEvent`) | Catalog Item Metadata | Structured key first appearance/origin/death events |
| `publisher`, `imprint` | Catalog Item Metadata | Publishing imprint and publisher |
| `releaseDate`, `coverDate`, `barcode` | Catalog Item Metadata | Release publishing timeline and UPC |
| `variant`, `variantDescription` | Catalog Item Metadata | Variant cover and edition details |
| `pageCount`, `country`, `language` | Catalog Item Metadata | Publication physical and localization specs |
| `rawOrSlabbed`, `gradingCompany`, `grade` | Personal Data | Slab and condition metrics |
| `signedBy`, `labelType`, `customLabel` | Personal Data | Autographs and grading labels |
| `pricePaid`, `location`, `lastBagBoardDate`| Personal Data | Storage and acquisition records |
| `valuations` (`ValuationSnapshot`) | Personal Data | Valuation snapshots (e.g. CovrPrice, manual) |

### 2. Manga
| Field | Scope | Description |
|---|---|---|
| `nativeTitle`, `romajiTitle`, `englishTitle` | Catalog Item Metadata | Multi-lingual work titles |
| `authors`, `artists` | Catalog Item Metadata | Mangaka creators |
| `demographic`, `genres`, `themes` | Catalog Item Metadata | Target demographic (Shonen, Seinen, etc.) and genres |
| `readingDirection` | Catalog Item Metadata | Right-to-left canonical direction |
| `originalPublisher`, `serialization` | Catalog Item Metadata | Original Japanese publisher and magazine |
| `volumeNumber`, `chapterCount`, `totalVolumes`| Catalog Item Metadata | Tankobon volume and chapter specs |
| `editionFormat` (tankobon, kanzenban, etc.) | Catalog Item Metadata | Physical edition format |
| `isbn`, `barcode`, `localizedPublisher` | Catalog Item Metadata | Regional publication identifiers |
| `condition`, `pricePaid`, `location` | Personal Data | Copy status and shelf placement |
| `signedBy`, `slipcoverPresent`, `obiStripPresent` | Personal Data | Manga-specific collector preservation elements |

### 3. Anime
| Field | Scope | Description |
|---|---|---|
| `nativeTitle`, `romajiTitle`, `englishTitle` | Catalog Item Metadata | Anime work titles |
| `format` (TV, Movie, OVA, ONA, Special) | Catalog Item Metadata | Production format |
| `studios`, `producers`, `sourceMaterial` | Catalog Item Metadata | Animation studios and origin |
| `episodeCount`, `episodeRuntime` | Catalog Item Metadata | Runtime specs |
| `season`, `seasonYear`, `airingStatus` | Catalog Item Metadata | Broadcast timeline |
| `physicalRelease` (Blu-ray, DVD, Box Set) | Catalog Item Metadata | Home video physical release |
| `region`, `discCount`, `packaging`, `hdr` | Catalog Item Metadata | Video media specifications |
| `condition`, `storageDevice`, `storageSlot`| Personal Data | Copy location and state |
| `watchSessions`, `progress` | Derived / Session | Personal tracking history |

### 4. Book
| Field | Scope | Description |
|---|---|---|
| `title`, `subtitle`, `sortTitle`, `synopsis`| Catalog Item Metadata | Canonical book title and overview |
| `authors`, `genres`, `subjects` | Catalog Item Metadata | Authors, topics, and classification |
| `originalTitle`, `originalLanguage` | Catalog Item Metadata | Original publication language |
| `format` (Hardcover, Paperback, Audiobook) | Catalog Item Metadata | Edition format |
| `isbn`, `publisher`, `imprint`, `dewey`, `loc` | Catalog Item Metadata | Library classification and ISBN |
| `printing`, `firstEdition`, `numberLine` | Catalog Item Metadata | Print run identifiers |
| `heightMm`, `widthMm`, `pageCount` | Catalog Item Metadata | Physical book dimensions |
| `audiobook` (`narrator`, `durationMinutes`)| Catalog Item Metadata | Audiobook-specific metadata |
| `condition`, `signedBy`, `pricePaid` | Personal Data | Personal copy condition |
| `dustJacketPresent`, `dustJacketCondition` | Personal Data | Dust jacket collector data |

### 5. Game
| Field | Scope | Description |
|---|---|---|
| `title`, `franchise`, `series`, `genres` | Catalog Item Metadata | Canonical game IP and series |
| `developers`, `publishers` | Catalog Item Metadata | Game studio and publisher |
| `platform`, `releaseRegion`, `edition` | Catalog Item Metadata | Console platform, region, and edition |
| `barcode`, `ageRating`, `languages` | Catalog Item Metadata | Package identifiers and rating |
| `completeness` (Loose, CIB, New, Sealed) | Personal Data | Packaging completeness |
| `hasBox`, `hasManual`, `valueLocked` | Personal Data | Box/manual presence and valuation lock |
| `valuations` | Personal Data | User-owned multi-tier valuation snapshots; external provider IDs are excluded from the v1 model |

### 6. Board Game
| Field | Scope | Description |
|---|---|---|
| `title`, `originalTitle`, `synopsis` | Catalog Item Metadata | Game identity and description |
| `designers`, `artists`, `publishers` | Catalog Item Metadata | Game designers and art team |
| `minPlayers`, `maxPlayers`, `bestPlayers` | Catalog Item Metadata | Player count recommendations |
| `minPlaytimeMinutes`, `maxPlaytimeMinutes` | Catalog Item Metadata | Play duration |
| `complexityWeight`, `mechanics`, `categories` | Catalog Item Metadata | BGG complexity and game mechanics |
| `bggRating`, `bggRank`, `yearPublished` | Catalog Item Metadata | Provider score and release year |
| `editionLanguage`, `editionRegion`, `barcode`| Catalog Item Metadata | Regional printing |
| `componentCondition`, `componentCompleteness`| Personal Data | Condition and missing piece notes |
| `isSleeved`, `hasCustomInsert`, `paintedMiniatures`| Personal Data | Collector upgrades and storage notes |
| `playSessions`, `playStats` | Derived / Session | Dynamic session tracking and win stats |

### 7. Movie
| Field | Scope | Description |
|---|---|---|
| `title`, `originalTitle`, `sortTitle` | Catalog Item Metadata | Canonical movie title |
| `directors`, `cast`, `crew`, `studios` | Catalog Item Metadata | Film creators and production entities |
| `runtimeMinutes`, `genres`, `mpaaRating` | Catalog Item Metadata | Media duration and classification |
| `format` (4K UHD, Blu-ray, DVD, VHS) | Catalog Item Metadata | Physical packaging format |
| `aspectRatio`, `hdrFormats`, `audioTracks` | Catalog Item Metadata | Release technical presentation |
| `region`, `discCount`, `distributor` | Catalog Item Metadata | Distributor and region coding |
| `condition`, `storageLocation`, `pricePaid` | Personal Data | Personal collection records |

### 8. TV
| Field | Scope | Description |
|---|---|---|
| `seriesTitle`, `originalTitle`, `synopsis` | Catalog Item Metadata | TV show identity |
| `creators`, `cast`, `networks`, `genres` | Catalog Item Metadata | Network and creative credits |
| `seasonCount`, `episodeCount`, `status` | Catalog Item Metadata | Series structure and airing status |
| `seasons` (`TvSeasonMetadata`), `episodes` | Catalog Item Metadata | Canonical seasons and episode graph |
| `boxSetRelease` (Blu-ray, DVD), `discs` | Catalog Item Metadata | Physical home release |
| `condition`, `storageLocation` | Personal Data | Personal copy data |
| `episodeSeenState`, `watchHistory` | Derived / Session | User viewing tracking |

### 9. Music
| Field | Scope | Description |
|---|---|---|
| `title`, `artist`, `originalReleaseDate` | Catalog Item Metadata | Canonical album and recording artist |
| `credits` (performers, producers, engineers)| Catalog Item Metadata | Studio recording and artistic credits |
| `genres`, `studio`, `isLive` | Catalog Item Metadata | Music classification and live/studio status |
| `catalogNumber`, `format`, `label`, `tracks` | Catalog Item Metadata | Record label, disc format, and tracklist |
| `mediaOrDiscCount`, `barcode`, `country` | Catalog Item Metadata | Physical release specifications |
| `signedBy`, `lastCleanedDate`, `storageSlot`| Personal Data | Autographs and record maintenance |
| `matrixRunouts` (`MusicMatrixRunout`) | Personal Data | Matrix/runout pressing identification |
| `listeningSessions`, `musicListeningStats` | Derived / Session | Play history and session logging |
