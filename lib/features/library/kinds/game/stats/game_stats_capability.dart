import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:flutter/material.dart';

class GameStatsCapability implements LibraryStatsCapability {
  const GameStatsCapability();

  @override
  LibraryOwnedFinancialSummary buildOwnedFinancialSummary(
      LibraryWorkspaceSource entry) {
    return LibraryOwnedFinancialSummary(
      pricePaidCents: entry.pricePaidCents,
      sellPriceCents: entry.sellPriceCents,
      currency: entry.currency,
    );
  }

  @override
  LibraryStatsMetadataProjection? buildMetadataProjection(
      LibraryWorkspaceSource entry) {
    final catalog = entry.catalogItem;
    final metadata = catalog?.kindMetadata;
    if (catalog == null || metadata is! GameCatalogMetadata) return null;
    final secondary =
        (metadata.publishers.firstOrNull ?? metadata.developers.firstOrNull)
            ?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup:
          (metadata.series ?? metadata.franchise ?? metadata.title).trim(),
      secondaryGroup: secondary,
      hasCover: catalog.displayCoverUrl?.trim().isNotEmpty == true,
      hasSynopsis: metadata.synopsis?.trim().isNotEmpty == true ||
          catalog.synopsis?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.platforms.isNotEmpty ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate:
          metadata.releaseDate != null || catalog.releaseDate != null,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindModule type,
  ) =>
      const [];

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindModule type,
  ) =>
      const [];
}
