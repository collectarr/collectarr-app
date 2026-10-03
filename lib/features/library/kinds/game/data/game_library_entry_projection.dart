import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';

/// Projects Game's typed entry model into structural collection summaries.
final class GameLibraryEntryProjection {
  const GameLibraryEntryProjection._();

  static GameLibraryEntry? fromDispatch(LibraryEntryDispatch? dispatch) {
    final value = dispatch?.value;
    return value is GameLibraryEntry ? value : null;
  }

  static LibraryEntrySummary toSummary(GameLibraryEntry item) {
    return LibraryEntrySummary(
      ref: LibraryEntryRef(
        kind: CatalogMediaKind.game,
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
