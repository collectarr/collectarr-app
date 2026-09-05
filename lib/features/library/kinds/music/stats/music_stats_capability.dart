import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

/// Music-specific collection aggregates: tracks, formats, artists, and labels.
final class MusicStatsCapability implements LibraryStatsCapability {
  const MusicStatsCapability();

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRuntime type,
  ) {
    final tracks = totalTracks(state.entries);
    final media = totalMedia(state.entries);
    return [
      if (tracks > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.queue_music_outlined,
          label: 'Tracks',
          value: tracks.toString(),
        ),
      if (media > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.album_outlined,
          label: 'Media',
          value: media.toString(),
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
      LibraryStatsDistributionCard(
        title: 'Formats',
        values: countFormats(state.entries),
      ),
    ];
  }

  static int totalTracks(Iterable<ShelfEntry> entries) {
    return entries.fold<int>(
      0,
      (total, entry) =>
          total +
          (_metadata(entry) == null ? 0 : _trackCount(_metadata(entry)!)),
    );
  }

  static int totalMedia(Iterable<ShelfEntry> entries) {
    return entries.fold<int>(
      0,
      (total, entry) =>
          total +
          (_metadata(entry) == null ? 0 : _mediaCount(_metadata(entry)!)),
    );
  }

  static Map<String, int> countArtists(Iterable<ShelfEntry> entries) {
    return _countMany(
        entries,
        (metadata) => [
              if (metadata.artist != null) metadata.artist!,
            ]);
  }

  static Map<String, int> countGenres(Iterable<ShelfEntry> entries) {
    return _countMany(entries, (metadata) => metadata.genres);
  }

  static Map<String, int> countFormats(Iterable<ShelfEntry> entries) {
    return _countMany(
        entries,
        (metadata) => [
              if (metadata.physicalFormatLabel != null)
                metadata.physicalFormatLabel!,
              if (metadata.physicalFormat != null) metadata.physicalFormat!,
              for (final release in metadata.releases)
                if (release.format != null) release.format!,
            ]);
  }

  static Map<String, int> countLabels(Iterable<ShelfEntry> entries) {
    return _countMany(
        entries,
        (metadata) => [
              if (metadata.recordLabel != null) metadata.recordLabel!,
              if (metadata.publisher != null) metadata.publisher!,
              for (final release in metadata.releases)
                if (release.label != null) release.label!,
            ]);
  }

  static MusicCatalogMetadata? _metadata(ShelfEntry entry) {
    final metadata = entry.catalogItem?.kindMetadata;
    return metadata is MusicCatalogMetadata ? metadata : null;
  }

  static int _trackCount(MusicCatalogMetadata metadata) {
    if (metadata.trackCount != null) return metadata.trackCount!;
    if (metadata.tracks.isNotEmpty) return metadata.tracks.length;
    return metadata.releases.fold<int>(
      0,
      (total, release) => total + release.tracks.length,
    );
  }

  static int _mediaCount(MusicCatalogMetadata metadata) {
    final explicit = metadata.releases.fold<int>(
      0,
      (total, release) => total + (release.mediaOrDiscCount ?? 0),
    );
    if (explicit > 0) return explicit;
    return metadata.releases.length;
  }

  static Map<String, int> _countMany(
    Iterable<ShelfEntry> entries,
    Iterable<String> Function(MusicCatalogMetadata metadata) valuesFor,
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
