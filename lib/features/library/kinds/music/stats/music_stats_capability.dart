import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

/// Music-specific collection aggregates: tracks, formats, artists, and labels.
final class MusicStatsCapability implements LibraryStatsCapability {
  const MusicStatsCapability();

  @override
  LibraryOwnedFinancialSummary buildOwnedFinancialSummary(
      LibraryWorkspaceSource entry) {
    return LibraryOwnedFinancialSummary(
      pricePaidCents: entry.pricePaidCents,
      sellPriceCents: entry.sellPriceCents,
      currency: entry.currency,
    );
  }

  @override
  LibraryStatsMetadataProjection? buildMetadataProjection(
      LibraryWorkspaceSource entry) {
    final catalog = entry.catalogTransport;
    final metadata = _metadata(entry);
    if (catalog == null || metadata == null) return null;
    final secondary = (metadata.publisher ?? metadata.recordLabel)?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: metadata.artist?.trim(),
      secondaryGroup: secondary,
      hasCover: catalog.displayCoverUrl?.trim().isNotEmpty == true,
      hasSynopsis: metadata.synopsis?.trim().isNotEmpty == true ||
          catalog.synopsis?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate:
          metadata.originalReleaseDate != null || catalog.releaseDate != null,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindModule type,
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
    LibraryKindModule type,
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

  static int totalTracks(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) =>
          total +
          (_metadata(entry) == null ? 0 : _trackCount(_metadata(entry)!)),
    );
  }

  static int totalMedia(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) =>
          total +
          (_metadata(entry) == null ? 0 : _mediaCount(_metadata(entry)!)),
    );
  }

  static Map<String, int> countArtists(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(
        entries,
        (metadata) => [
              if (metadata.artist != null) metadata.artist!,
            ]);
  }

  static Map<String, int> countGenres(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(entries, (metadata) => metadata.genres);
  }

  static Map<String, int> countFormats(
      Iterable<LibraryWorkspaceSource> entries) {
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

  static Map<String, int> countLabels(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(
        entries,
        (metadata) => [
              if (metadata.recordLabel != null) metadata.recordLabel!,
              if (metadata.publisher != null) metadata.publisher!,
              for (final release in metadata.releases)
                if (release.label != null) release.label!,
            ]);
  }

  static MusicCatalogMetadata? _metadata(LibraryWorkspaceSource entry) {
    final metadata = entry.catalogTransport?.toTransportItem().kindMetadata;
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
    Iterable<LibraryWorkspaceSource> entries,
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
