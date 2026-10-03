import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';

/// Projects Manga's typed entry model into structural collection summaries.
final class MangaLibraryEntryProjection {
  const MangaLibraryEntryProjection._();

  static MangaLibraryEntry? fromDispatch(
      LibraryEntryDispatch? dispatch) {
    final value = dispatch?.value;
    return value is MangaLibraryEntry ? value : null;
  }

  static LibraryEntrySummary toSummary(MangaLibraryEntry item) {
    return LibraryEntrySummary(
      ref: LibraryEntryRef(
        kind: CatalogMediaKind.manga,
        id: LibraryEntryId(item.id.value),
      ),
      sourceCatalogRef: item.sourceCatalogRef,
      isDigital: item.isDigital,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      deletedAt: item.deletedAt,
      purchaseDate: item.purchaseDate,
      purchaseStore: item.purchaseStore,
      pricePaidCents: item.pricePaidCents,
      currency: item.currency,
      soldAt: item.soldAt,
      soldTo: item.soldTo,
      sellPriceCents: item.sellPriceCents,
      marketValueCents: item.marketValueCents,
      ownerLabel: item.ownerLabel,
      locationId: item.locationId,
      notes: item.personalNotes,
      hasNotes: item.personalNotes?.trim().isNotEmpty == true,
    );
  }
}
