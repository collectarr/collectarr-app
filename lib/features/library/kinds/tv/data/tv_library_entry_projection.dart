import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';

/// Projects TV's typed entry model into structural collection summaries.
final class TvLibraryEntryProjection {
  const TvLibraryEntryProjection._();

  static TvLibraryEntry? fromDispatch(LibraryEntryDispatch? dispatch) {
    final value = dispatch?.value;
    return value is TvLibraryEntry ? value : null;
  }

  static LibraryEntrySummary toSummary(TvLibraryEntry item) {
    return LibraryEntrySummary(
      ref: LibraryEntryRef(
        kind: CatalogMediaKind.tv,
        id: LibraryEntryId(item.id.value),
      ),
      sourceCatalogRef: item.sourceCatalogRef,
      isDigital: item.personal.isDigital,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      deletedAt: item.deletedAt,
      purchaseDate: item.personal.purchaseDate,
      purchaseStore: item.personal.purchaseStore,
      pricePaidCents: item.personal.pricePaidCents,
      currency: item.personal.currency,
      soldAt: item.personal.soldAt,
      soldTo: item.personal.soldTo,
      sellPriceCents: item.personal.sellPriceCents,
      marketValueCents: item.personal.marketValueCents,
      ownerLabel: item.personal.ownerLabel,
      locationId: item.personal.locationId,
      notes: item.personal.personalNotes,
      hasNotes: item.personal.personalNotes?.trim().isNotEmpty == true,
    );
  }
}
