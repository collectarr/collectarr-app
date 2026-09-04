import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';

class MovieValueCapability implements LibraryValueCapability {
  const MovieValueCapability();

  @override
  LibraryCollectionValueSummary? resolveCollectionValueSummary(
    Iterable<ShelfEntry> entries,
  ) {
    final valuedEntries = entries
        .where(
          (entry) =>
              entry.isOwned &&
              entry.ownedItem?.marketValueCents != null &&
              entry.ownedItem?.currency?.trim().isNotEmpty == true,
        )
        .toList(growable: false);
    if (valuedEntries.isEmpty) return null;

    final currencies = {
      for (final entry in valuedEntries) entry.ownedItem!.currency!.trim(),
    };
    return LibraryCollectionValueSummary(
      valuedCount: valuedEntries.length,
      totalValueCents: currencies.length > 1
          ? null
          : valuedEntries.fold<int>(
              0,
              (total, entry) => total + entry.ownedItem!.marketValueCents!,
            ),
      currency: currencies.length == 1 ? currencies.single : null,
      hasMixedCurrencies: currencies.length > 1,
    );
  }

  @override
  int? resolveProviderValueCents(LibraryProjectionRuntime item) {
    if (item.dto case MovieWorkspaceDto dto) {
      return dto.media.providerValueCents ?? dto.metadata?.providerValueCents;
    }
    final metadata = item.source.catalogItem?.kindMetadata;
    if (metadata is MovieCatalogMetadata) {
      return metadata.providerValueCents;
    }
    if (metadata is MovieMedia) {
      return metadata.providerValueCents;
    }
    return null;
  }
}
