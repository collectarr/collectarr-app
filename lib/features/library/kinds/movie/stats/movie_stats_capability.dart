import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

class MovieStatsCapability implements LibraryStatsCapability {
  const MovieStatsCapability();

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRuntime type,
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
    LibraryKindRuntime type,
  ) {
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
    ];
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
