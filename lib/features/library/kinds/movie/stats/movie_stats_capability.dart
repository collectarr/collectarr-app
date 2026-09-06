import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

class MovieStatsCapability implements LibraryStatsCapability {
  const MovieStatsCapability();

  @override
  LibraryOwnedFinancialSummary buildOwnedFinancialSummary(ShelfEntry entry) {
    final owned = entry.ownedItem;
    return LibraryOwnedFinancialSummary(
      pricePaidCents: owned?.pricePaidCents,
      sellPriceCents: owned?.sellPriceCents,
      currency: owned?.currency,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindModule type,
  ) {
    final runtime = totalRuntimeMinutes(state.entries);
    final averageRating = averageAudienceRating(state.entries);
    return [
      if (runtime > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.timer_outlined,
          label: 'Runtime',
          value: formatRuntime(runtime),
        ),
      if (averageRating != null)
        LibraryStatsTileDescriptor(
          icon: Icons.star_outline,
          label: 'Avg. rating',
          value: averageRating.toStringAsFixed(1),
        ),
    ];
  }

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindModule type,
  ) {
    final seasonGap = _numberedGapSummary(
      state.entries,
      (entry) {
        final payload = entry.catalogItem?.payload;
        final rawSeason = payload?['season_number'] ??
            (payload?['series'] as Map?)?['season_number'];
        if (rawSeason == null) return null;
        return (rawSeason as num?)?.toInt() ??
            int.tryParse(rawSeason.toString());
      },
    );

    return [
      LibraryStatsRankedCard(
        title: 'Top Genres',
        values: countGenres(state.entries),
      ),
      LibraryStatsRankedCard(
        title: 'Top Directors',
        values: countDirectors(state.entries),
      ),
      LibraryStatsDistributionCard(
        title: 'Formats',
        values: countFormats(state.entries),
      ),
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
      final payload = entry.catalogItem?.payload;
      final seriesTitle = ((payload?['series_title'] ??
              (payload?['series'] as Map?)?['series_title']) as String?)
          ?.trim();
      final number = numberFor(entry);
      if (seriesTitle == null || seriesTitle.isEmpty || number == null) {
        continue;
      }
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

  static int totalRuntimeMinutes(Iterable<ShelfEntry> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_metadata(entry)?.runtimeMinutes ?? 0),
    );
  }

  static double? averageAudienceRating(Iterable<ShelfEntry> entries) {
    var total = 0.0;
    var count = 0;
    for (final entry in entries) {
      final raw = _metadata(entry)?.audienceRating;
      final rating = double.tryParse(raw?.trim() ?? '');
      if (rating == null) continue;
      total += rating;
      count++;
    }
    return count == 0 ? null : total / count;
  }

  static Map<String, int> countGenres(Iterable<ShelfEntry> entries) {
    return _countMany(entries, (metadata) => metadata.genres);
  }

  static Map<String, int> countDirectors(Iterable<ShelfEntry> entries) {
    return _countMany(
      entries,
      (metadata) => metadata.directors.map((credit) => credit.name),
    );
  }

  static Map<String, int> countFormats(Iterable<ShelfEntry> entries) {
    return _countMany(
      entries,
      (metadata) => [
        if (metadata.physicalFormatLabel?.trim().isNotEmpty == true)
          metadata.physicalFormatLabel!,
        if (metadata.physicalFormatLabel?.trim().isEmpty != false &&
            metadata.physicalFormat?.trim().isNotEmpty == true)
          metadata.physicalFormat!,
      ],
    );
  }

  static String formatRuntime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder == 0 ? '${hours}h' : '${hours}h ${remainder}m';
  }

  static MovieCatalogMetadata? _metadata(ShelfEntry entry) {
    final metadata = entry.catalogItem?.kindMetadata;
    return metadata is MovieCatalogMetadata ? metadata : null;
  }

  static Map<String, int> _countMany(
    Iterable<ShelfEntry> entries,
    Iterable<String> Function(MovieCatalogMetadata metadata) valuesFor,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final metadata = _metadata(entry);
      if (metadata == null) continue;
      final seen = <String>{};
      for (final raw in valuesFor(metadata)) {
        final value = raw.trim();
        if (value.isEmpty) continue;
        final key = value.toLowerCase();
        if (!seen.add(key)) continue;
        counts[value] = (counts[value] ?? 0) + 1;
      }
    }
    return counts;
  }
}

class _MissingNumberSummary {
  const _MissingNumberSummary(this.seriesTitle, this.missingNumbers);

  final String seriesTitle;
  final List<int> missingNumbers;
}
