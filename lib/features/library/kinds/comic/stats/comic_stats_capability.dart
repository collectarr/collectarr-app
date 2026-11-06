import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/comic/stats/collection_stats.dart';
import 'package:collectarr_app/features/library/stats/family_stats_page.dart';
import 'package:flutter/material.dart';

class ComicStatsCapability
    implements LibraryStatsCapability, LibraryCollectionStatsContributor {
  const ComicStatsCapability();

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
    final metadata = _comicMetadata(entry);
    if (metadata == null) return null;
    final primary = (metadata.seriesTitle ?? metadata.title).trim();
    final secondary = (metadata.publisher ?? metadata.imprint)?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: primary,
      secondaryGroup: secondary,
      hasCover: metadata.coverImageUrl?.trim().isNotEmpty == true,
      hasSynopsis: metadata.synopsis?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate: metadata.releaseDate != null,
      hasItemNumber: metadata.issueNumber?.trim().isNotEmpty == true,
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
      ComicCollectionStats(entries: entries);

  static ComicCatalogItem? _comicMetadata(LibraryWorkspaceContext entry) {
    final catalog = entry.kindPresentationData;
    return catalog is ComicWorkspaceData ? catalog.comic : null;
  }
}
