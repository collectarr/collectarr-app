import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_stats_capability.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

class TvStatsCapability implements LibraryStatsCapability {
  const TvStatsCapability();

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryTypeConfig type,
  ) =>
      const [];

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryTypeConfig type,
  ) {
    final seasonGap = _numberedGapSummary(
      state.entries,
      (entry) {
        final payload = entry.catalogItem?.kindMetadata.toSyncPayload();
        final rawSeason = payload?['season_number'] ??
            (payload?['series'] as Map?)?['season_number'];
        if (rawSeason == null) return null;
        return (rawSeason as num?)?.toInt() ??
            int.tryParse(rawSeason.toString());
      },
    );

    return [
      if (seasonGap != null)
        LibraryMissingSequenceCard(
          title: 'Missing seasons',
          selectedSeries: seasonGap.seriesTitle,
          missingValues: seasonGap.missingNumbers,
          valueLabelBuilder: (value) => 'Season $value',
        ),
    ];
  }

  static _MissingNumberSummary? _numberedGapSummary(
    List<ShelfEntry> entries,
    int? Function(ShelfEntry entry) numberFor,
  ) {
    _MissingNumberSummary? best;
    final seriesNumbers = <String, Set<int>>{};
    for (final entry in entries) {
      if (!entry.isOwned) continue;
      final payload = entry.catalogItem?.kindMetadata.toSyncPayload();
      final seriesTitle = ((payload?['series_title'] ??
              (payload?['series'] as Map?)?['series_title']) as String?)
          ?.trim();
      final number = numberFor(entry);
      if (seriesTitle == null || seriesTitle.isEmpty || number == null)
        continue;
      seriesNumbers.putIfAbsent(seriesTitle, () => <int>{}).add(number);
    }
    for (final series in seriesNumbers.entries) {
      final sorted = series.value.toList(growable: false)..sort();
      if (sorted.length < 2) continue;
      final missing = <int>[];
      for (var number = sorted.first; number <= sorted.last; number++) {
        if (!series.value.contains(number)) missing.add(number);
      }
      if (missing.isEmpty) continue;
      final summary = _MissingNumberSummary(series.key, missing);
      if (best == null ||
          summary.missingNumbers.length > best.missingNumbers.length) {
        best = summary;
      }
    }
    return best;
  }
}

class _MissingNumberSummary {
  const _MissingNumberSummary(this.seriesTitle, this.missingNumbers);
  final String seriesTitle;
  final List<int> missingNumbers;
}
