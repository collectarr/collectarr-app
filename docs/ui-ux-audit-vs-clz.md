# UI/UX Audit: Collectarr App vs CLZ Web/Mobile

> Audit date: 2026-05-27
> CLZ source: clz.com/comics/web, clz.com/movies/web, clz.com/comics/mobile, clz.com/movies/mobile + latest "What's New" posts (through May 2026)
> Collectarr source: codebase analysis of lib/features/

---

## Executive Summary

Collectarr already matches or exceeds CLZ in **core collection management** (add, edit, search, sort, filter, group, multiple view modes, hyperlink filtering, custom fields, location tracking, multi-image support, barcode scanning). It also has structural advantages CLZ cannot match: **unified all-media-type app**, **self-hosted**, **no subscription**, and **admin console**.

The remaining UX gaps fall into three buckets:
1. **Visual polish** — CLZ's mature view modes have more visual flair (slab frames, collection value totals, eBay links)
2. **Workflow shortcuts** — CLZ has a few time-saving patterns Collectarr hasn't copied yet
3. **Missing niche features** — domain-specific features for comics/movies that are high-signal for power users

---

## 1. Layout & Navigation

| Aspect | CLZ Web | Collectarr | Verdict |
|--------|---------|------------|---------|
| **Primary navigation** | Tab strip per media type (each is a separate app) | Bottom nav: Libraries / Shelf / Calendar / Admin / Settings | ✅ Collectarr better — unified shell, no app-switching |
| **Library kind switching** | N/A (separate apps) | Top tab strip or left rail, configurable placement | ✅ Collectarr better |
| **Folder/sidebar panel** | Left panel with customizable folder grouping (series, box, grade, creator) | Left sidebar with series facets + alpha-jump bar | ≈ Parity — both offer hierarchical faceted navigation |
| **Detail panel placement** | Always right-side split | Right / Bottom / Hidden (configurable) | ✅ Collectarr better — more layout flexibility |
| **Responsive width** | Recent update (May 2026): wider edit screen adapts to browser width | Desktop-first with adaptive layouts | ≈ Parity |
| **Multiple collections** | Excel-like tabs at bottom (e.g. "Physical", "Digital", "Sold") | Quick views (Owned, Wishlist, Missing covers/metadata/grade) + smart lists | 🟡 Different model — CLZ tabs are user-created; Collectarr's smart lists + quick views are more powerful but less obvious for simple "my vs my wife's" splits |

### Recommendation
- **Add "Collection tabs" or "User lists"** — CLZ's Excel-tab metaphor for splitting "my comics" vs "sold" vs "for sale" vs "spouse's" is extremely discoverable. Collectarr's smart lists can do this but need a friendlier creation UX.

---

## 2. View Modes

| View Mode | CLZ Web | Collectarr | Verdict |
|-----------|---------|------------|---------|
| **List** (table) | ✅ Customizable columns, sortable headers | ✅ Customizable columns, sortable headers, inline editing | ✅ Collectarr better (inline editing) |
| **Covers** (grid) | ✅ Adjustable thumbnail size | ✅ Adjustable size, drag-to-select | ✅ Collectarr better |
| **Horizontal cards** | ✅ Cover + metadata side-by-side | ✅ Card mode with cover + title + badges + metadata | ≈ Parity |
| **Vertical cards** | ✅ Cover on top, metadata below | ✅ cardFlow mode | ≈ Parity |
| **Shelves** | ✅ Physical shelf metaphor (spine view) | ✅ Shelves mode | ≈ Parity |
| **Slab frames** | ✅ Generated CGC/CBCS slab overlay on cover in ALL view modes (Feb 2026) | ❌ Missing | 🔴 Gap — high-value visual for comic collectors |

### Recommendation
- **Slab frame overlay** — For graded comics, render a visual CGC/CBCS-style slab border around the cover image. CLZ recently expanded this to all view modes (covers, cards, shelves). This is a *visual delight* feature that makes graded comics instantly recognizable.

---

## 3. Add / Search Flow

| Aspect | CLZ Web | Collectarr | Verdict |
|--------|---------|------------|---------|
| **Add by barcode** | Camera scanner (mobile) + CLZ Scanner companion app (web) | Built-in barcode scan + batch scan | ✅ Collectarr better (no companion app needed) |
| **Add by title** | Search CLZ Core database | Search collectarr-core catalog + provider search (9 providers) | ✅ Collectarr better (more providers) |
| **Add by series checkbox** | ✅ Find series → checkbox issues you own | ✅ Series browsing + volume/issue selection | ≈ Parity |
| **One-by-one barcode mode** | ✅ New in Nov 2025 — scan barcode, review, add, repeat | ✅ Batch scan with per-item review | ≈ Parity |
| **Cover art scanning** | ✅ Image recognition identifies comic by cover photo | ❌ Missing | 🟡 Low priority — impressive but niche |
| **Pre-fill screen** | ✅ Set default values (box, location, grade) before batch add — orange highlights show pre-filled fields | ✅ Prefill settings dialog | ≈ Parity |
| **"In collection" indicator** | ✅ Shows which results you already own while adding | 🟡 Partial — add dialog shows matches but could be more prominent | 🟡 Minor gap |

### Recommendation
- **Prominent "already owned" badge in add results** — When searching to add, CLZ shows a clear visual indicator on results you already have. Collectarr should make this more visible to prevent duplicates (a key CLZ selling point per reviews).

---

## 4. Edit Flow

| Aspect | CLZ Web | Collectarr | Verdict |
|--------|---------|------------|---------|
| **Tabbed edit dialog** | ✅ General / Value / Plot / Creators / Characters / Personal / Custom Fields / My Images — tab order now customizable (May 2026) | ✅ Catalog / Collection / Images / Custom fields / Tracking / Price / Metadata corrections | ≈ Parity |
| **Tab order customization** | ✅ Drag-to-reorder tabs (new May 2026) | ❌ Fixed tab order | 🟡 Minor gap |
| **Edit Multiple (bulk edit)** | ✅ Redesigned Oct 2023 — batch field overwrite with field picker | ✅ Bulk edit dialog for selected items | ≈ Parity |
| **Wider edit on wide screens** | ✅ Adaptive width (new May 2026) | ✅ Already responsive | ≈ Parity |

### Recommendation
- **Draggable edit tab reorder** — Low-effort, high-satisfaction for power users who always start on the same tab.

---

## 5. Detail Page

| Aspect | CLZ Web | Collectarr | Verdict |
|--------|---------|------------|---------|
| **Cover + metadata hero** | ✅ Large cover, title, issue# | ✅ Hero image, title, action buttons | ≈ Parity |
| **Hyperlink filtering** | ✅ Click creator/character/series/story-arc/grade → filter list (new Apr 2026) | ✅ Already implemented — click any creator/character/series/publisher to filter | ✅ Collectarr was first |
| **Key issue markers** | ✅ 1st appearance, cameo, death, iconic cover — prominently badged | ✅ Key badge on items | ≈ Parity |
| **eBay search links** | ✅ Auto-generated eBay search URL per item (Jul 2025) | ❌ Missing | 🟡 Nice-to-have |
| **YouTube trailers** | ✅ Embedded trailers for movies | ✅ Trailer section with YouTube detection | ≈ Parity |
| **Activity timeline** | ❌ No history | ✅ Activity timeline (ownership changes, grade changes, edits) | ✅ Collectarr better |
| **Related items** | Basic series navigation | ✅ Series relations, creator spotlight, volume/season list, bundle releases | ✅ Collectarr better |
| **Multiple images** | ✅ New May 2026 — upload front/back/extra images | ✅ Gallery with upload/delete, captions, sort order | ✅ Collectarr better (captions + sort) |

---

## 6. Sorting, Filtering, Grouping

| Aspect | CLZ Web | Collectarr | Verdict |
|--------|---------|------------|---------|
| **Sort** | By series/issue, date, value, title, year, runtime, rating, etc. | Multi-rule sorting (primary/secondary/tertiary) per column asc/desc | ✅ Collectarr better (multi-rule) |
| **Filter** | Folder-based + search box + hyperlink click-through | Ownership, tracking status, loan status, date ranges, custom fields, advanced search + hyperlink filtering | ✅ Collectarr better |
| **Group / folders** | By series, storage box, grade, creator, genre, year | 20+ group modes: series, storyArc, character, title, publisher, year, genre, country, language, ageRating, format, director, creator, writer, artist, penciller, colorist, letterer, coverArtist, editor, location, ownership, grade, condition, tags | ✅ Collectarr much better |
| **Series completeness** | ✅ Filter by "completed" status | 🟡 Basic series view, no "missing issues" list | 🟡 Gap — CLZ can show which issues are missing from a series run |
| **Column chooser** | ✅ Pick visible columns for list view | ✅ Column chooser dialog | ≈ Parity |
| **Folder chooser** | ✅ Pick which folder types appear in sidebar | ✅ Sidebar configuration | ≈ Parity |

### Recommendation
- **Missing issues list** — For comics especially, show a "You have 47/100 issues — here are the 53 you're missing" view per series. This is a marquee CLZ feature for completionists.

---

## 7. Collection Management (Personal Data)

| Aspect | CLZ Web | Collectarr | Verdict |
|--------|---------|------------|---------|
| **Purchase price/date/store** | ✅ | ✅ | ≈ Parity |
| **Sell price/date/buyer** | ✅ | ✅ (soldAt, sellPriceCents, soldTo) | ≈ Parity |
| **Grade + grading company + label type** | ✅ CGC/CBCS-specific with custom labels | 🟡 Basic condition field | 🔴 Gap for comic collectors |
| **Custom fields** | ✅ New Feb 2026 — user-defined fields | ✅ Per-media-type custom fields, searchable, CSV support | ✅ Collectarr better (per-type + CSV) |
| **Location / storage box** | ✅ | ✅ Hierarchical locations with rename/reparent/sync | ✅ Collectarr better |
| **Loan tracking** | 🟡 Basic | ✅ Full loan tracking with overdue highlighting | ✅ Collectarr better |
| **Collection value totals** | ✅ Via CovrPrice integration | ❌ No summed value dashboard | 🟡 Gap — easy to compute from existing price fields |
| **Reading/watch tracking** | ❌ CLZ is catalog-only | ✅ Tracking status (planned/in-progress/completed/paused/dropped/repeating) | ✅ Collectarr better |
| **Personal rating** | ✅ Star rating | 🟡 Rating field exists but less prominent | 🟡 Minor gap |

### Recommendations
- **CGC/CBCS grading fields** — Add `grading_company`, `grade_value` (numeric), `label_type` (Universal/Signature/JSA), `certification_number` to the owned item model. This is table-stakes for slab collectors.
- **Collection value summary** — Add a "My Collection Value" widget (sum of purchase prices, sum of current values if available) to the Shelf/Collection tab. Dead simple, high perceived value.
- **Star rating prominence** — Make the personal rating widget more prominent on the detail page (5-star display vs. just a number field).

---

## 8. Cloud / Sync

| Aspect | CLZ | Collectarr | Verdict |
|--------|-----|------------|---------|
| **Cloud sync** | ✅ CLZ Cloud — proprietary, between mobile and web | ✅ collectarr-sync — self-hosted, full Drift DB sync, multi-user JWT | ✅ Collectarr better (self-hosted, no vendor lock-in) |
| **Online sharing** | ✅ Public URL to browse your collection | ❌ No public sharing URL | 🟡 Gap — "share my collection" link is a social feature |
| **Backup** | ✅ Cloud-based | ✅ Local backup/restore | ≈ Different trade-offs |

### Recommendation
- **Public collection share link** — Low priority but high "show off" value. Could be a read-only web view served by core.

---

## 9. Import / Export

| Aspect | CLZ | Collectarr | Verdict |
|--------|-----|------------|---------|
| **CSV import/export** | ✅ | ✅ Strong CSV + CLZ import-export coverage | ≈ Parity |
| **CLZ format import** | ✅ (own format) | ✅ CLZ XML import | ✅ Collectarr better (can import from CLZ) |
| **Third-party imports** | ❌ | ❌ (Yamtrack has Trakt/Simkl/MAL/AniList/Kitsu imports) | ≈ Both miss this |

---

## 10. Platform-Specific CLZ Features Collectarr Doesn't Need

These are CLZ features that don't make sense for Collectarr's architecture:

| Feature | Reason to Skip |
|---------|---------------|
| CLZ Scanner companion app | Collectarr has built-in barcode scanning |
| Separate subscription per media type | Collectarr is unified — this is an advantage |
| CLZ Cloud proprietary sync | collectarr-sync is superior |
| IMDb partnership branding | Collectarr uses TMDb (open) |
| CovrPrice integration | Requires paid API partnership — custom fields can store values manually |

---

## Priority Ranking of UX Gaps

### P0 — High Impact, Reasonable Effort
| # | Gap | Impact | Effort |
|---|-----|--------|--------|
| 1 | **Missing issues / series completeness** | Marquee feature for comic collectors — "you need issues 3, 7, 12, 45" | Medium — need series→issue mapping from ComicVine |
| 2 | **CGC/CBCS grading fields** (company, grade, label type, cert#) | Core for slab collectors, blocks slab frame feature | Low — add fields to OwnedItem model |
| 3 | **Collection value summary widget** | High perceived value, trivial to implement from existing price fields | Low |
| 4 | **"Already owned" indicator in add dialog** | Prevents duplicates — #1 CLZ user complaint prevented | Low |

### P1 — Medium Impact
| # | Gap | Impact | Effort |
|---|-----|--------|--------|
| 5 | **Slab frame visual overlay** | Visual delight for graded comics | Medium — need to render slab border + label on cover |
| 6 | **Draggable edit tab reorder** | Power user convenience | Low |
| 7 | **Star rating widget prominence** | More satisfying than a number input | Low |
| 8 | **eBay search link per item** | Quick price check for sellers | Low — template URL from title + issue |

### P2 — Nice to Have
| # | Gap | Impact | Effort |
|---|-----|--------|--------|
| 9 | **Collection tabs** (user-created collection splits) | Organizational flexibility | Medium |
| 10 | **Public share link** | Social / show-off feature | High — needs web frontend or core read-only API |
| 11 | **Cover art scanning** (image recognition) | Impressive but niche | Very High — ML model or external API |
| 12 | **Random pick / "shake phone"** | Fun but trivial | Very Low |

---

## Collectarr Advantages CLZ Cannot Match

| Advantage | Details |
|-----------|---------|
| **Unified all-media app** | 1 app covers 9 media types vs. 5 separate CLZ apps/subscriptions |
| **Self-hosted / open-source** | No vendor lock-in, no cloud dependency, full data ownership |
| **Free** | No subscription (CLZ: €20/yr mobile + €40/yr web per media type) |
| **9 metadata providers** | MusicBrainz, TMDb, ComicVine, AniList, MangaDex, OpenLibrary, BGG, IGDB, + core catalog |
| **Manga + Anime + Board Games** | CLZ has no apps for these media types at all |
| **Admin console** | Catalog management, metadata correction, duplicate merge, user management |
| **Activity timeline** | Full audit trail of changes — CLZ has nothing comparable |
| **Tracking status** | Planned/in-progress/completed/paused/dropped — CLZ is catalog-only |
| **Inline list editing** | Edit cells directly in list view |
| **Multi-rule sorting** | Primary + secondary + tertiary sort rules |
| **20+ grouping modes** | Far more than CLZ's ~8 folder types |
| **Loan tracking with overdue** | Full loan management with due date and overdue highlighting |
| **Desktop-native performance** | Flutter desktop vs. web browser — faster rendering for large collections |

---

## Summary

Collectarr is already a **feature-superset** of CLZ in most dimensions. The remaining gaps are primarily in **comics-specific collector features** (slab frames, CGC grading, series completeness, CovrPrice-style values) and a few **quality-of-life polish items** (collection value totals, star rating widget, eBay links).

The P0 items (missing issues list, CGC grading fields, value summary, duplicate prevention in add dialog) would close the most visible parity gaps. The visual polish items (slab frames, star ratings) would make the app feel more premium.

No architectural changes are needed — all gaps are additive features on top of the existing Drift schema, UI framework, and provider infrastructure.
