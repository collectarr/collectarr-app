# Collectarr Kind Field Ownership & Scope Classification

This document defines the canonical classification of fields across all 9 active kinds in Collectarr according to the three distinct architecture levels: **Media / Work**, **Release / Edition**, and **Copy / Personal**.

---

## Scope Definitions

1. **Media / Work**
   - Canonical work-level semantics shared across all formats, pressings, languages, and editions.
   - *Examples*: Title, original title, creators (authors, directors, developers, designers), synopsis, genres, original language, original release date, runtime, demographic, mechanics.

2. **Release / Edition**
   - Physical or digital publishing artifact and package characteristics.
   - *Examples*: Format (Blu-ray, Paperback, Vinyl LP, Cartridge), ISBN, barcode, publisher, edition title, country, packaging, disc count, HDR formats, catalog number, matrix/runout specifications.

3. **Copy / Personal**
   - Personal collector attributes unique to a specific physical or digital copy owned by the user.
   - *Examples*: Condition, grade, price paid, purchase date, storage location, signed by, dust jacket status, component completeness, missing pieces notes, matrix runouts, valuation snapshots.

4. **Derived / Session**
   - Runtime calculated or aggregated statistics from session tracking (reading, listening, watching, playing).
   - *Examples*: Play count, last played, listen count, last listened, watch progress, session history.

---

## Kind-by-Kind Ownership Matrix

### 1. Comic
| Field | Scope | Description |
|---|---|---|
| `title`, `series`, `issueNumber` | Media / Work | Canonical series and issue identification |
| `writers`, `artists`, `coverArtists` | Media / Work | Issue creative contributors |
| `characters`, `storyArcs` | Media / Work | Canonical comic universe entities |
| `keyEvents` (`ComicKeyEvent`) | Media / Work | Structured key first appearance/origin/death events |
| `publisher`, `imprint` | Release / Edition | Publishing imprint and publisher |
| `releaseDate`, `coverDate`, `barcode` | Release / Edition | Release publishing timeline and UPC |
| `variant`, `variantDescription` | Release / Edition | Variant cover and edition details |
| `pageCount`, `country`, `language` | Release / Edition | Publication physical and localization specs |
| `rawOrSlabbed`, `gradingCompany`, `grade` | Copy / Personal | Slab and condition metrics |
| `signedBy`, `labelType`, `customLabel` | Copy / Personal | Autographs and grading labels |
| `pricePaid`, `location`, `lastBagBoardDate`| Copy / Personal | Storage and acquisition records |
| `valuations` (`ValuationSnapshot`) | Copy / Personal | Valuation snapshots (e.g. CovrPrice, manual) |

### 2. Manga
| Field | Scope | Description |
|---|---|---|
| `nativeTitle`, `romajiTitle`, `englishTitle` | Media / Work | Multi-lingual work titles |
| `authors`, `artists` | Media / Work | Mangaka creators |
| `demographic`, `genres`, `themes` | Media / Work | Target demographic (Shonen, Seinen, etc.) and genres |
| `readingDirection` | Media / Work | Right-to-left canonical direction |
| `originalPublisher`, `serialization` | Media / Work | Original Japanese publisher and magazine |
| `volumeNumber`, `chapterCount`, `totalVolumes`| Release / Edition | Tankobon volume and chapter specs |
| `editionFormat` (tankobon, kanzenban, etc.) | Release / Edition | Physical edition format |
| `isbn`, `barcode`, `localizedPublisher` | Release / Edition | Regional publication identifiers |
| `condition`, `pricePaid`, `location` | Copy / Personal | Copy status and shelf placement |
| `signedBy`, `slipcoverPresent`, `obiStripPresent` | Copy / Personal | Manga-specific collector preservation elements |

### 3. Anime
| Field | Scope | Description |
|---|---|---|
| `nativeTitle`, `romajiTitle`, `englishTitle` | Media / Work | Anime work titles |
| `format` (TV, Movie, OVA, ONA, Special) | Media / Work | Production format |
| `studios`, `producers`, `sourceMaterial` | Media / Work | Animation studios and origin |
| `episodeCount`, `episodeRuntime` | Media / Work | Runtime specs |
| `season`, `seasonYear`, `airingStatus` | Media / Work | Broadcast timeline |
| `physicalRelease` (Blu-ray, DVD, Box Set) | Release / Edition | Home video physical release |
| `region`, `discCount`, `packaging`, `hdr` | Release / Edition | Video media specifications |
| `condition`, `storageDevice`, `storageSlot`| Copy / Personal | Copy location and state |
| `watchSessions`, `progress` | Derived / Session | Personal tracking history |

### 4. Book
| Field | Scope | Description |
|---|---|---|
| `title`, `subtitle`, `sortTitle`, `synopsis`| Media / Work | Canonical book title and overview |
| `authors`, `genres`, `subjects` | Media / Work | Authors, topics, and classification |
| `originalTitle`, `originalLanguage` | Media / Work | Original publication language |
| `format` (Hardcover, Paperback, Audiobook) | Release / Edition | Edition format |
| `isbn`, `publisher`, `imprint`, `dewey`, `loc` | Release / Edition | Library classification and ISBN |
| `printing`, `firstEdition`, `numberLine` | Release / Edition | Print run identifiers |
| `heightMm`, `widthMm`, `pageCount` | Release / Edition | Physical book dimensions |
| `audiobook` (`narrator`, `durationMinutes`)| Release / Edition | Audiobook-specific metadata |
| `condition`, `signedBy`, `pricePaid` | Copy / Personal | Personal copy condition |
| `dustJacketPresent`, `dustJacketCondition` | Copy / Personal | Dust jacket collector data |

### 5. Game
| Field | Scope | Description |
|---|---|---|
| `title`, `franchise`, `series`, `genres` | Media / Work | Canonical game IP and series |
| `developers`, `publishers` | Media / Work | Game studio and publisher |
| `platform`, `releaseRegion`, `edition` | Release / Edition | Console platform, region, and edition |
| `barcode`, `ageRating`, `languages` | Release / Edition | Package identifiers and rating |
| `completeness` (Loose, CIB, New, Sealed) | Copy / Personal | Packaging completeness |
| `hasBox`, `hasManual`, `valueLocked` | Copy / Personal | Box/manual presence and valuation lock |
| `priceChartingId`, `valuations` | Copy / Personal | Multi-tier game valuation snapshots |

### 6. Board Game
| Field | Scope | Description |
|---|---|---|
| `title`, `originalTitle`, `synopsis` | Media / Work | Game identity and description |
| `designers`, `artists`, `publishers` | Media / Work | Game designers and art team |
| `minPlayers`, `maxPlayers`, `bestPlayers` | Media / Work | Player count recommendations |
| `minPlaytimeMinutes`, `maxPlaytimeMinutes` | Media / Work | Play duration |
| `complexityWeight`, `mechanics`, `categories` | Media / Work | BGG complexity and game mechanics |
| `bggRating`, `bggRank`, `yearPublished` | Media / Work | Provider score and release year |
| `editionLanguage`, `editionRegion`, `barcode`| Release / Edition | Regional printing |
| `componentCondition`, `componentCompleteness`| Copy / Personal | Condition and missing piece notes |
| `isSleeved`, `hasCustomInsert`, `paintedMiniatures`| Copy / Personal | Collector upgrades and storage notes |
| `playSessions`, `playStats` | Derived / Session | Dynamic session tracking and win stats |

### 7. Movie
| Field | Scope | Description |
|---|---|---|
| `title`, `originalTitle`, `sortTitle` | Media / Work | Canonical movie title |
| `directors`, `cast`, `crew`, `studios` | Media / Work | Film creators and production entities |
| `runtimeMinutes`, `genres`, `mpaaRating` | Media / Work | Media duration and classification |
| `format` (4K UHD, Blu-ray, DVD, VHS) | Release / Edition | Physical packaging format |
| `aspectRatio`, `hdrFormats`, `audioTracks` | Release / Edition | Release technical presentation |
| `region`, `discCount`, `distributor` | Release / Edition | Distributor and region coding |
| `condition`, `storageLocation`, `pricePaid` | Copy / Personal | Personal collection records |

### 8. TV
| Field | Scope | Description |
|---|---|---|
| `seriesTitle`, `originalTitle`, `synopsis` | Media / Work | TV show identity |
| `creators`, `cast`, `networks`, `genres` | Media / Work | Network and creative credits |
| `seasonCount`, `episodeCount`, `status` | Media / Work | Series structure and airing status |
| `seasons` (`TvSeasonMetadata`), `episodes` | Media / Work | Canonical seasons and episode graph |
| `boxSetRelease` (Blu-ray, DVD), `discs` | Release / Edition | Physical home release |
| `condition`, `storageLocation` | Copy / Personal | Personal copy data |
| `episodeSeenState`, `watchHistory` | Derived / Session | User viewing tracking |

### 9. Music
| Field | Scope | Description |
|---|---|---|
| `title`, `artist`, `originalReleaseDate` | Media / Work | Canonical album and recording artist |
| `credits` (performers, producers, engineers)| Media / Work | Studio recording and artistic credits |
| `genres`, `studio`, `isLive` | Media / Work | Music classification and live/studio status |
| `catalogNumber`, `format`, `label`, `tracks` | Release / Edition | Record label, disc format, and tracklist |
| `mediaOrDiscCount`, `barcode`, `country` | Release / Edition | Physical release specifications |
| `signedBy`, `lastCleanedDate`, `storageSlot`| Copy / Personal | Autographs and record maintenance |
| `matrixRunouts` (`MusicMatrixRunout`) | Copy / Personal | Matrix/runout pressing identification |
| `listeningSessions`, `musicListeningStats` | Derived / Session | Play history and session logging |
