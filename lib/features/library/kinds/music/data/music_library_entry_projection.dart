import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';

/// Projects Music's typed entry model into structural collection summaries.
final class MusicLibraryEntryProjection {
  const MusicLibraryEntryProjection._();

  static MusicLibraryEntry? fromDispatch(LibraryEntryDispatch? dispatch) {
    final value = dispatch?.value;
    return value is MusicLibraryEntry ? value : null;
  }

  static LibraryEntrySummary toSummary(MusicLibraryEntry item) {
    return LibraryEntrySummary(
      ref: LibraryEntryRef(
        kind: CatalogMediaKind.music,
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
