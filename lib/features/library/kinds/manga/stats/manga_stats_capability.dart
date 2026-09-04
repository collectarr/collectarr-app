import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

class MangaStatsCapability implements LibraryStatsCapability {
  const MangaStatsCapability();

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRuntime type,
  ) =>
      const [];

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRuntime type,
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
    Iterable<ShelfEntry> entries,
  ) {
    final seriesNumbers = <String, Set<int>>{};
    for (final entry in entries) {
      if (!entry.isOwned) continue;
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
    Iterable<ShelfEntry> entries,
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

  static MangaMetadata? _mangaMetadata(ShelfEntry entry) {
    final metadata = entry.catalogItem?.kindMetadata;
    return metadata is MangaMetadata ? metadata : null;
  }

  static String? _seriesTitle(MangaMetadata metadata) {
    final title = metadata.seriesTitle ?? metadata.series?.seriesTitle;
    final trimmed = title?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static int? _volumeNumber(MangaMetadata metadata) {
    if (metadata.volumeNumber != null) return metadata.volumeNumber;
    final seriesNumber = metadata.series?.volumeNumber;
    if (seriesNumber != null) {
      final parsed = int.tryParse(seriesNumber.trim());
      if (parsed != null) return parsed;
    }
    final itemNumber = metadata.itemNumber?.trim();
    if (itemNumber == null || itemNumber.isEmpty) return null;
    return int.tryParse(itemNumber);
  }
}

class _MissingNumberSummary {
  const _MissingNumberSummary(this.seriesTitle, this.missingNumbers);
  final String seriesTitle;
  final List<int> missingNumbers;
}
