# 🔍 CLZ + Yamtrack Feature Gap Analysis

> Comparison of CLZ and Yamtrack features vs Collectarr's current state.
> 
> ✅ = Collectarr has it &nbsp;|&nbsp; 🟡 = Partial &nbsp;|&nbsp; ❌ = Missing

---

## 🦸 Comics

| Feature | CLZ | Collectarr | Notes |
|---------|-----|------------|-------|
| Barcode scanning | ✅ | ✅ | Camera + manual fallback |
| Cover art scanning (image recognition) | ✅ | ❌ | CLZ identifies comics by cover photo |
| Comic values (CovrPrice integration) | ✅ | ❌ | CLZ partners with CovrPrice for market values |
| Key issue markers | ✅ | ❌ | First appearances, cameos, deaths, iconic covers |
| Slab/graded frames | ✅ | ❌ | Visual CGC/CBCS slab display in grid views |
| Custom user-defined fields | ✅ | ✅ | Per-media-type text fields, searchable, CSV support |
| Multiple images per item | ✅ | ✅ | Local item photos with captions and sort order |
| Purchase price + date | ✅ | ✅ | pricePaidCents, purchaseDate on OwnedItem |
| Sell price + date / Sold tracking | ✅ | ✅ | soldAt, sellPriceCents, soldTo fields |
| Grading company + grade | ✅ | 🟡 | Collectarr has basic condition, not CGC/CBCS-specific |
| Variant cover browsing | ✅ | ✅ | Provider candidates expose variants |
| Hyperlink filtering | ✅ | ✅ | Click a writer/artist name → filter to matching items |
| Cloud sync (multi-device) | ✅ | ✅ | Via collectarr-sync |
| Wishlist | ✅ | ✅ | |
| Series/run completeness tracking | ✅ | 🟡 | Basic series view, no "missing issues" list |

---

## 📚 Books

| Feature | CLZ | Collectarr | Notes |
|---------|-----|------------|-------|
| ISBN barcode scanning | ✅ | ✅ | |
| 40M+ ISBN database (97% hit rate) | ✅ | 🟡 | Collectarr uses OpenLibrary — decent but smaller |
| Reading history tracking | ✅ | ✅ | Per-book read sessions (multiple reads, dates, ratings) via the read-history section, backed by the session store |
| Reader field (per-person tracking) | ✅ | ❌ | Track different readers on same book |
| Custom user-defined fields | ✅ | ✅ | Per-media-type text fields, searchable |
| Multiple images per item | ✅ | ✅ | Local photos with captions |
| Purchase price + date | ✅ | ✅ | |
| Location tracking (shelf/room) | ✅ | ✅ | Hierarchical locations with rename/reparent/sync |
| Personal ratings + notes | ✅ | 🟡 | Notes exist, no star rating field |
| Cloud sync | ✅ | ✅ | |
| Wishlist | ✅ | ✅ | |
| Random pick ("shake phone") | ✅ | ✅ | Toolbar random pick action is now available |
| Hyperlink filtering | ✅ | ✅ | Click any creator/publisher to filter |

---

## 🎬 Movies / TV

| Feature | CLZ | Collectarr | Notes |
|---------|-----|------------|-------|
| Barcode scanning | ✅ | ✅ | |
| IMDb integration (cast/crew/ratings) | ✅ | 🟡 | Collectarr uses TMDb — has cast/crew but no IMDb ratings |
| Physical format tracking (DVD/Blu-ray/4K/VHS/LaserDisc) | ✅ | ✅ | Edition model + HDR formats + features fields |
| YouTube trailer links | ✅ | ✅ | Trailer section with YouTube detection on detail page |
| Custom episodes | ✅ | ❌ | User-added episode data |
| Custom user-defined fields | ✅ | ✅ | Per-media-type text fields, searchable |
| Multiple images per item | ✅ | ✅ | Local photos with captions |
| Purchase price + date | ✅ | ✅ | |
| Location tracking | ✅ | ✅ | Hierarchical locations with rename/reparent/sync |
| Random movie picker | ✅ | ❌ | Shake phone to pick random movie |
| Cloud sync | ✅ | ✅ | |
| Wishlist | ✅ | ✅ | |
| Hyperlink filtering | ✅ | ✅ | Click any creator/character/series/publisher to filter |

---

## 🎵 Music

| Feature | CLZ | Collectarr | Notes |
|---------|-----|------------|-------|
| Barcode scanning (4M+ barcodes, 94% hit) | ✅ | ✅ | Collectarr uses MusicBrainz |
| Track list display | ✅ | ❌ | MusicBrainz has data, not surfaced in App |
| Format tracking (CD/vinyl/cassette) | ✅ | 🟡 | Physical format field exists, not as detailed |
| Vinyl condition + pressing details | ✅ | ❌ | |
| Custom user-defined fields | ✅ | ✅ | Per-media-type text fields, searchable |
| Multiple images per item | ✅ | ✅ | Local photos with captions |
| Purchase price + date | ✅ | ✅ | |
| Location tracking | ✅ | ✅ | Hierarchical locations with rename/reparent/sync |
| Cloud sync | ✅ | ✅ | |
| Wishlist | ✅ | ✅ | |
| Hyperlink filtering | ✅ | ✅ | Click any creator to filter |

---

## 🎮 Games

| Feature | CLZ | Collectarr | Notes |
|---------|-----|------------|-------|
| Barcode scanning | ✅ | ✅ | |
| Game values (PriceCharting: Loose/CIB/New) | ✅ | ❌ | CLZ integrates PriceCharting for daily values |
| Platform/region/edition variants | ✅ | 🟡 | Basic edition model, not as granular |
| Console/hardware cataloging | ✅ | ❌ | CLZ can catalog consoles, controllers, figures |
| YouTube trailer links | ✅ | ✅ | Trailer section with YouTube detection on detail page |
| Custom user-defined fields | ✅ | ✅ | Per-media-type text fields, searchable |
| Multiple images per item | ✅ | ✅ | Local photos with captions |
| Purchase price + date | ✅ | ✅ | |
| Location tracking | ✅ | ✅ | Hierarchical locations with rename/reparent/sync |
| Cloud sync | ✅ | ✅ | |
| Wishlist | ✅ | ✅ | |
| Hyperlink filtering | ✅ | ✅ | Click any creator/publisher to filter |

---

## 🌐 Cross-Cutting Gaps (All Library Types)

> 💡 Most of these are **personal collection data** — they live in the App's local Drift DB and sync through `collectarr-sync`. They do NOT belong in Core's canonical catalog.

| Feature | Priority | Where | Notes |
|---------|----------|-------|-------|
| **Custom user-defined fields** | ✅ Done | 📱 App + 🔄 Sync | Per-media-type text fields, searchable, CSV support |
| **Purchase price/date + sell price/date** | ✅ Done | 📱 App + 🔄 Sync | soldAt, sellPriceCents, soldTo on OwnedItem |
| **Multiple images per item** | ✅ Done | 📱 App + 🔄 Sync | Local photos with captions and sort order |
| **Series/hierarchical shelf grouping** | ✅ Done | 📱 App | Series/volume/season grouping now ships in the shared library stack |
| **Collection value totals** | 🟠 Medium | 📱 App | Computed from local price fields, no Core involvement |
| **Hyperlink filtering** | ✅ Done | 📱 App | Click any creator/character/series/publisher to filter the library |
| **Location tracking** | ✅ Done | 📱 App + 🔄 Sync | Hierarchical locations with rename/reparent/description/sync |
| **Trailer links** | ✅ Done | 📱 App | YouTube-detected trailers on detail page for movies/TV/games |
| **Random pick / shake phone** | ✅ Done | 📱 App | Toolbar random pick action is available |
| **Cover art scanning (visual recognition)** | 🟡 Low | 🎯 Core | Only comics; would need ML model or external API |
| **Sold items tracking** | ✅ Done | 📱 App + 🔄 Sync | soldAt, sellPriceCents, soldTo fields |
| **Pricing integrations** | 🟡 Low | 🎯 Core | CovrPrice (comics), PriceCharting (games) — paid external APIs |

---

## 🧭 Yamtrack Gaps (And Which Ones Matter)

> Yamtrack is tracker-first and self-hosted. Some gaps are worth copying; others are product-direction choices, not regressions.

| Area | Yamtrack | Collectarr | Notes |
|------|----------|------------|-------|
| Tracking history / activity timeline | ✅ | ❌ | Yamtrack records add/start/restart/progress history per media item |
| Custom manual entries for unsupported media | ✅ | 🟡 | Collectarr has manual add for supported kinds, not true arbitrary unsupported media |
| Personal + collaborative lists | ✅ | ❌ | Useful for curated shortlists beyond owned/wishlist |
| Calendar / ICS feed for upcoming releases | ✅ | ✅ | In-app calendar aggregates release/owned/loan/watch dates and exports to a standard `.ics` file |
| Notifications via Apprise | ✅ | ❌ | Lower priority unless release tracking becomes a first-class workflow |
| Direct imports from Trakt / Simkl / MAL / AniList / Kitsu | ✅ | ❌ | This is one of Yamtrack's strongest onboarding advantages |
| Jellyfin / Plex / Emby integrations | ✅ | ❌ | Important only if Collectarr pivots toward tracker automation |
| Multi-user self-hosted accounts | ✅ | 🟡 | Core has auth/admin, but app UX is still very single-user/local-first |
| OIDC / social auth | ✅ | ❌ | Lower priority than collector parity unless hosting/distribution goals change |
| CSV round-trip import / export | ✅ | ✅ | Collectarr already has strong CSV / CLZ import-export coverage |

### What Is Actually Worth Pulling From Yamtrack

- Direct tracker/import integrations are the most valuable Yamtrack-inspired gap because they reduce manual re-entry.
- Tracking history is worth considering because it adds auditability without changing Collectarr's collector-first positioning.
- Lists are a good fit if they stay local-first and collection-oriented.
- Calendar, notifications, media-server webhooks, and social/OIDC should stay behind CLZ-parity work unless the product direction shifts.

---

## ⚙️ Provider API Usage Audit

### What Yamtrack Seems To Do Better

- It keeps media-type-to-provider selection simple and explicit: TMDB for movies/TV, MAL for anime, MAL or MangaUpdates for manga, IGDB for games, Hardcover/OpenLibrary for books, ComicVine for comics, BGG for board games.
- It centralizes outbound API traffic behind one shared services layer with per-provider rate limiting.
- It caches provider metadata in Redis for hours for at least some sources and exposes source-specific env tuning.
- It appears to fetch heavier provider metadata when needed for details/imports, rather than preloading full normalized previews for every visible search result.

### What Collectarr Already Does Well

- Core has structured provider search, retry/backoff, cacheable provider search results, and comic-specific fallback/enrichment logic.
- The app now handles mixed-provider result sets more honestly instead of pretending the requested provider alone produced everything.
- Provider image mirroring and typed normalized previews give Collectarr better long-term control over canonical metadata than a pure passthrough model.

### Current Collectarr Problems / Inefficiencies

1. **Every app search fans out more than it needs to.** The add dialog runs Core catalog search and then automatically runs provider search for supported kinds, even when local/catalog hits may already be enough.
2. **Provider preview prefetch is too expensive.** After provider search, the app prefetches full previews in batches for almost every result. Each preview hits Core's preview endpoint, which calls `provider.get_item()` and `normalize()` again.
3. **Previews are not backed by a dedicated server-side preview cache.** Search results are cached in Core, but preview requests are effectively fresh fetch-and-normalize work keyed only by the dialog's in-memory cache.
4. **Preview and ingest duplicate upstream work.** A candidate can go through `search` -> `preview` -> `ingest`, with preview and ingest both doing heavy provider fetch/normalize steps instead of reusing a hydrated result or short-lived token.
5. **Non-admin users still pay preview cost.** The app can prefetch provider previews even for users who cannot ingest and may only ever add a local placeholder entry.
6. **Image mirroring can still sit on the interactive hot path.** If provider image mirroring is enabled, search results may synchronously stabilize image URLs before returning, which is safer but can add latency to already expensive provider operations.

### Recommended Direction

1. Stop automatic provider search after every successful core search; make it demand-driven or only trigger it when local/core confidence is low.
2. Replace N preview requests with either selection-only preview loading or a dedicated batch preview endpoint.
3. Add a short-lived Core preview cache keyed by `(provider, provider_item_id)`.
4. Reuse preview hydration for ingest so the same candidate is not fetched and normalized twice.
5. Keep image mirroring off the synchronous search path when possible; prefer background fill or cache-warm behavior.

---

## 💎 Collectarr Advantages Over CLZ

| Feature | Collectarr | CLZ |
|---------|------------|-----|
| **Self-hosted / open-source** | ✅ | ❌ Proprietary SaaS |
| **Unified app for ALL media types** | ✅ Single app | ❌ 5 separate apps, 5 subscriptions |
| **No subscription required** | ✅ Free | ❌ ~€20/yr mobile + €40/yr web per media type |
| **9 metadata providers** | ✅ | ❌ CLZ uses proprietary "Core" database |
| **Admin console** | ✅ | ❌ |
| **Manga + Anime support** | ✅ AniList + MangaDex | ❌ No CLZ manga/anime app |
| **Board game support** | ✅ BGG provider | ❌ No CLZ board game app |
| **Offline-first local DB** | ✅ Full Drift DB | 🟡 CLZ stores in cloud, local is cache |
| **CSV import/export** | ✅ | 🟡 CLZ export is limited |
| **Desktop (Windows) support** | ✅ Native Flutter | 🟡 CLZ desktop discontinued → web only |
