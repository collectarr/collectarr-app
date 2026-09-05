import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';

class ComicValueCapability implements LibraryValueCapability {
  const ComicValueCapability();

  @override
  LibraryCollectionValueSummary? resolveCollectionValueSummary(
    Iterable<ShelfEntry> entries,
  ) {
    final valuedEntries = entries.where((entry) {
      final ownedItem = entry.ownedItem;
      final details = ownedItem?.details;
      return entry.isOwned &&
          details is ComicOwnedDetails &&
          details.coverPriceCents != null &&
          ownedItem?.currency != null;
    }).toList(growable: false);
    if (valuedEntries.isEmpty) {
      return null;
    }
    final currencies = {
      for (final entry in valuedEntries) entry.ownedItem!.currency!,
    };
    return LibraryCollectionValueSummary(
      valuedCount: valuedEntries.length,
      totalValueCents: currencies.length > 1
          ? null
          : valuedEntries.fold<int>(
              0,
              (total, entry) {
                final details = entry.ownedItem!.details;
                return total +
                    (details is ComicOwnedDetails
                        ? details.coverPriceCents ?? 0
                        : 0);
              },
            ),
      currency: currencies.length == 1 ? currencies.single : null,
      hasMixedCurrencies: currencies.length > 1,
    );
  }

  @override
  int? resolveProviderValueCents(LibraryProjectionRuntime item) {
    if (item.dto case ComicWorkspaceDto dto) {
      return dto.metadata?.publishing?.coverPriceCents ??
          dto.comic.publishing.coverPriceCents;
    }
    final catalog = item.source.catalogItem;
    final metadata = catalog?.kindMetadata;
    if (metadata is ComicCatalogMetadata) {
      return metadata.publishing?.coverPriceCents;
    }
    final payload = catalog?.payload ?? const <String, dynamic>{};
    final publishing = payload['publishing'] as Map?;
    return (publishing?['cover_price_cents'] as num?)?.toInt();
  }
}
