# 🔍 CLZ Feature Gap Analysis

> Comparison of CLZ (clz.com) features vs Collectarr's current state, broken down per library type.
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
| Hyperlink filtering | ✅ | ❌ | Click a writer/artist name → filter to matching items |
| Cloud sync (multi-device) | ✅ | ✅ | Via collectarr-sync |
| Wishlist | ✅ | ✅ | |
| Series/run completeness tracking | ✅ | 🟡 | Basic series view, no "missing issues" list |

---

## 📚 Books

| Feature | CLZ | Collectarr | Notes |
|---------|-----|------------|-------|
| ISBN barcode scanning | ✅ | ✅ | |
| 40M+ ISBN database (97% hit rate) | ✅ | 🟡 | Collectarr uses OpenLibrary — decent but smaller |
| Reading history tracking | ✅ | ❌ | Start/end dates, progress, multiple reads per book |
| Reader field (per-person tracking) | ✅ | ❌ | Track different readers on same book |
| Custom user-defined fields | ✅ | ✅ | Per-media-type text fields, searchable |
| Multiple images per item | ✅ | ✅ | Local photos with captions |
| Purchase price + date | ✅ | ✅ | |
| Location tracking (shelf/room) | ✅ | 🟡 | storageBox field exists |
| Personal ratings + notes | ✅ | 🟡 | Notes exist, no star rating field |
| Cloud sync | ✅ | ✅ | |
| Wishlist | ✅ | ✅ | |
| Random pick ("shake phone") | ✅ | ❌ | |
| Hyperlink filtering | ✅ | ❌ | |

---

## 🎬 Movies / TV

| Feature | CLZ | Collectarr | Notes |
|---------|-----|------------|-------|
| Barcode scanning | ✅ | ✅ | |
| IMDb integration (cast/crew/ratings) | ✅ | 🟡 | Collectarr uses TMDb — has cast/crew but no IMDb ratings |
| Physical format tracking (DVD/Blu-ray/4K/VHS/LaserDisc) | ✅ | 🟡 | Edition model exists, not as rich |
| YouTube trailer links | ✅ | ❌ | |
| Custom episodes | ✅ | ❌ | User-added episode data |
| Custom user-defined fields | ✅ | ✅ | Per-media-type text fields, searchable |
| Multiple images per item | ✅ | ✅ | Local photos with captions |
| Purchase price + date | ✅ | ✅ | |
| Location tracking | ✅ | 🟡 | storageBox field exists |
| Random movie picker | ✅ | ❌ | Shake phone to pick random movie |
| Cloud sync | ✅ | ✅ | |
| Wishlist | ✅ | ✅ | |
| Hyperlink filtering | ✅ | ❌ | |

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
| Location tracking | ✅ | 🟡 | storageBox field exists |
| Cloud sync | ✅ | ✅ | |
| Wishlist | ✅ | ✅ | |
| Hyperlink filtering | ✅ | ❌ | |

---

## 🎮 Games

| Feature | CLZ | Collectarr | Notes |
|---------|-----|------------|-------|
| Barcode scanning | ✅ | ✅ | |
| Game values (PriceCharting: Loose/CIB/New) | ✅ | ❌ | CLZ integrates PriceCharting for daily values |
| Platform/region/edition variants | ✅ | 🟡 | Basic edition model, not as granular |
| Console/hardware cataloging | ✅ | ❌ | CLZ can catalog consoles, controllers, figures |
| YouTube trailer links | ✅ | ❌ | |
| Custom user-defined fields | ✅ | ✅ | Per-media-type text fields, searchable |
| Multiple images per item | ✅ | ✅ | Local photos with captions |
| Purchase price + date | ✅ | ✅ | |
| Location tracking | ✅ | 🟡 | storageBox field exists |
| Cloud sync | ✅ | ✅ | |
| Wishlist | ✅ | ✅ | |
| Hyperlink filtering | ✅ | ❌ | |

---

## 🌐 Cross-Cutting Gaps (All Library Types)

> 💡 Most of these are **personal collection data** — they live in the App's local Drift DB and sync through `collectarr-sync`. They do NOT belong in Core's canonical catalog.

| Feature | Priority | Where | Notes |
|---------|----------|-------|-------|
| **Custom user-defined fields** | ✅ Done | 📱 App + 🔄 Sync | Per-media-type text fields, searchable, CSV support |
| **Purchase price/date + sell price/date** | ✅ Done | 📱 App + 🔄 Sync | soldAt, sellPriceCents, soldTo on OwnedItem |
| **Multiple images per item** | ✅ Done | 📱 App + 🔄 Sync | Local photos with captions and sort order |
| **Series/hierarchical shelf grouping** | 🔴 High | 📱 App | Group by series in sidebar — manga volumes, TV seasons, comic issues |
| **Collection value totals** | 🟠 Medium | 📱 App | Computed from local price fields, no Core involvement |
| **Hyperlink filtering** | 🟠 Medium | 📱 App | Click any field value to filter — pure UI feature |
| **Location tracking** | 🟡 Low-Med | 📱 App + 🔄 Sync | Shelf/box/room — personal data, Drift + sync |
| **Random pick / shake phone** | 🟡 Low | 📱 App | Fun "what should I read/watch/play" — pure UI |
| **Cover art scanning (visual recognition)** | 🟡 Low | 🎯 Core | Only comics; would need ML model or external API |
| **Sold items tracking** | ✅ Done | 📱 App + 🔄 Sync | soldAt, sellPriceCents, soldTo fields |
| **Pricing integrations** | 🟡 Low | 🎯 Core | CovrPrice (comics), PriceCharting (games) — paid external APIs |

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
