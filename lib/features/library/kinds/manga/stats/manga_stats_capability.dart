import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:flutter/material.dart';

class MangaStatsCapability implements LibraryStatsCapability {
  const MangaStatsCapability();

  @override
  LibraryEntryFinancialSummary buildEntryFinancialSummary(
      LibraryWorkspaceSource entry) {
    return LibraryEntryFinancialSummary(
      pricePaidCents: entry.pricePaidCents,
      sellPriceCents: entry.sellPriceCents,
      currency: entry.currency,
    );
  }

  @override
  LibraryStatsMetadataProjection? buildMetadataProjection(
      LibraryWorkspaceSource entry) {
    final catalog = entry.catalogData;
    final metadata = _mangaMetadata(entry);
    if (catalog == null || metadata == null) return null;
    final primary = (metadata.seriesTitle ?? catalog.title).trim();
    final secondary = metadata.publisher?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: primary,
      secondaryGroup: secondary,
      hasCover: catalog.coverImageUrl?.trim().isNotEmpty == true,
      hasSynopsis:
          libraryWorkspaceCatalogSynopsis(catalog)?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate:
          metadata.releaseDate != null || catalog.releaseDate != null,
      hasItemNumber:
          metadata.itemNumber != null || metadata.volumeNumber != null,
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
  ) {
    final volumeGap = _bestMissingVolumeSummary(state.entries);

    return [
      if (volumeGap != null)
        LibraryMissingSequenceCard(
          title: 'Missing volumes',
          selectedSeries: volumeGap.seriesTitle,
          missingValues: volumeGap.missingNumbers,
          valueLabelBuilder: (value) => 'Vol. $value',
        ),
    ];
  }

  static Map<String, List<int>> missingVolumeNumbers(
    Iterable<LibraryWorkspaceSource> entries,
  ) {
    final seriesNumbers = <String, Set<int>>{};
    for (final entry in entries) {
      if (!entry.isEntry) continue;
      final metadata = _mangaMetadata(entry);
      if (metadata == null) continue;
      final seriesTitle = _seriesTitle(metadata);
      final volumeNumber = _volumeNumber(metadata);
      if (seriesTitle == null || volumeNumber == null) continue;
      seriesNumbers.putIfAbsent(seriesTitle, () => <int>{}).add(volumeNumber);
    }

    final missingBySeries = <String, List<int>>{};
    for (final series in seriesNumbers.entries) {
      final sorted = series.value.toList(growable: false)..sort();
      if (sorted.length < 2) continue;
      final missing = <int>[];
      for (var number = sorted.first; number <= sorted.last; number++) {
        if (!series.value.contains(number)) missing.add(number);
      }
      if (missing.isNotEmpty) missingBySeries[series.key] = missing;
    }
    return missingBySeries;
  }

  static _MissingNumberSummary? _bestMissingVolumeSummary(
    Iterable<LibraryWorkspaceSource> entries,
  ) {
    final missingBySeries = missingVolumeNumbers(entries);
    _MissingNumberSummary? best;
    for (final series in missingBySeries.entries) {
      final summary = _MissingNumberSummary(series.key, series.value);
      if (best == null ||
          summary.missingNumbers.length > best.missingNumbers.length) {
        best = summary;
      }
    }
    return best;
  }

  static MangaMetadata? _mangaMetadata(LibraryWorkspaceSource entry) {
    final catalog = entry.catalogData;
    return catalog is MangaWorkspaceCatalogData ? catalog.metadata : null;
  }

  static String? _seriesTitle(MangaMetadata metadata) {
    final trimmed = metadata.seriesTitle?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static int? _volumeNumber(MangaMetadata metadata) => metadata.volumeNumber;
}

class _MissingNumberSummary {
  const _MissingNumberSummary(this.seriesTitle, this.missingNumbers);
  final String seriesTitle;
  final List<int> missingNumbers;
}
