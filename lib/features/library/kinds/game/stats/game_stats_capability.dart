import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/game/stats/game_collection_stats.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/stats/library_family_stats_page.dart';
import 'package:flutter/material.dart';

class GameStatsCapability
    implements LibraryStatsCapability, LibraryCollectionStatsContributor {
  const GameStatsCapability();

  @override
  LibraryEntryFinancialSummary buildEntryFinancialSummary(
      LibraryWorkspaceContext entry) {
    return LibraryEntryFinancialSummary(
      pricePaidCents: entry.pricePaidCents,
      sellPriceCents: entry.sellPriceCents,
      currency: entry.currency,
    );
  }

  @override
  LibraryStatsMetadataProjection? buildMetadataProjection(
      LibraryWorkspaceContext entry) {
    final metadata = _metadata(entry);
    if (metadata == null) return null;
    final secondary =
        (metadata.publisher ?? metadata.developers.firstOrNull)?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup:
          (metadata.seriesTitle ?? metadata.franchise ?? metadata.title).trim(),
      secondaryGroup: secondary,
      hasCover: metadata.coverImageUrl?.trim().isNotEmpty == true,
      hasSynopsis: metadata.synopsis?.trim().isNotEmpty == true ||
          metadata.synopsis?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.platforms.isNotEmpty ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate: metadata.releaseDate != null,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRegistration type,
  ) =>
      const [];

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) =>
      const [];

  @override
  Widget? buildCustomHeader(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) =>
      null;

  @override
  Widget? buildCustomStatsPage(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) =>
      LibraryFamilyStatsPage(type: type, state: state);

  @override
  Widget buildCollectionStats(
          BuildContext context, List<LibraryWorkspaceContext> entries) =>
      GameCollectionStats(entries: entries);

  static GameCatalogMetadata? _metadata(LibraryWorkspaceContext entry) {
    final catalog = entry.kindPresentationData;
    return catalog is GameWorkspaceData ? catalog.metadata : null;
  }
}
