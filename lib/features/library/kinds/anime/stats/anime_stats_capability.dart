import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

/// Anime-specific collection statistics.
///
/// Anime is represented as a series with episode metadata, so the useful
/// aggregate is episode volume and not the runtime/season semantics of the
/// generic video capability.
final class AnimeStatsCapability implements LibraryStatsCapability {
  const AnimeStatsCapability();

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRuntime type,
  ) {
    final episodes = totalEpisodes(state.entries);
    return [
      if (episodes > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.format_list_numbered_outlined,
          label: 'Episodes',
          value: episodes.toString(),
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
        title: 'Top Studios',
        values: countStudios(state.entries),
      ),
      LibraryStatsDistributionCard(
        title: 'Formats',
        values: countFormats(state.entries),
      ),
      LibraryStatsDistributionCard(
        title: 'Source Material',
        values: countSourceMaterial(state.entries),
      ),
    ];
  }

  static int totalEpisodes(Iterable<ShelfEntry> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_metadata(entry)?.episodeCount ?? 0),
    );
  }

  static Map<String, int> countGenres(Iterable<ShelfEntry> entries) {
    return _countMany(entries, (metadata) => metadata.genres);
  }

  static Map<String, int> countStudios(Iterable<ShelfEntry> entries) {
    return _countMany(entries, (metadata) => metadata.studios);
  }

  static Map<String, int> countFormats(Iterable<ShelfEntry> entries) {
    return _countMany(entries, (metadata) => [metadata.format.label]);
  }

  static Map<String, int> countSourceMaterial(Iterable<ShelfEntry> entries) {
    return _countMany(entries, (metadata) => [metadata.sourceMaterial.label]);
  }

  static AnimeMetadata? _metadata(ShelfEntry entry) {
    final metadata = entry.catalogItem?.kindMetadata;
    return metadata is AnimeMetadata ? metadata : null;
  }

  static Map<String, int> _countMany(
    Iterable<ShelfEntry> entries,
    Iterable<String> Function(AnimeMetadata metadata) valuesFor,
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
