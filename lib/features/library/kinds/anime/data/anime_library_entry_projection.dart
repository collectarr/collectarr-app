import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';

/// Projects Anime's typed entry model into structural collection summaries.
final class AnimeLibraryEntryProjection {
  const AnimeLibraryEntryProjection._();

  static AnimeLibraryEntry? fromDispatch(
      LibraryEntryDispatch? dispatch) {
    final value = dispatch?.value;
    return value is AnimeLibraryEntry ? value : null;
  }

  static LibraryEntrySummary toSummary(AnimeLibraryEntry item) {
    return LibraryEntrySummary(
      ref: LibraryEntryRef(
        kind: CatalogMediaKind.anime,
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
