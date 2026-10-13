import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

class MangaStatsCapability implements LibraryStatsCapability {
  const MangaStatsCapability();

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
    final metadata = _mangaMetadata(entry);
    if (metadata == null) return null;
    final primary = (metadata.seriesTitle ?? metadata.title).trim();
    final secondary = metadata.publisher?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: primary,
      secondaryGroup: secondary,
      hasCover: metadata.coverImageUrl?.trim().isNotEmpty == true,
      hasSynopsis:
          (metadata.synopsis ?? metadata.description)?.trim().isNotEmpty ==
              true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate: metadata.releaseDate != null,
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
      null;

  static Map<String, List<int>> missingVolumeNumbers(
    Iterable<LibraryWorkspaceContext> entries,
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
    Iterable<LibraryWorkspaceContext> entries,
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

  static MangaMetadata? _mangaMetadata(LibraryWorkspaceContext entry) {
    final catalog = entry.kindPresentationData;
    return catalog is MangaWorkspaceData ? catalog.metadata : null;
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
