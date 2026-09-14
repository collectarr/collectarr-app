import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
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
    final catalog = entry.catalogData;
    final music = _music(entry);
    final release =
        catalog is MusicWorkspaceCatalogData ? catalog.release : null;
    if (catalog == null || music == null) return null;
    final secondary = release?.publisher?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: music.artist?.trim(),
      secondaryGroup: secondary,
      hasCover: catalog.coverImageUrl?.trim().isNotEmpty == true,
      hasSynopsis: music.synopsis?.trim().isNotEmpty == true ||
          catalog.synopsis?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          release?.mediums.any(
                  (medium) => medium.mediumType?.trim().isNotEmpty == true) ==
              true,
      hasReleaseDate:
          music.originalReleaseDate != null || catalog.releaseDate != null,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRegistration type,
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
    LibraryKindRegistration type,
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
      (total, entry) => total + (_music(entry)?.trackCount ?? 0),
    );
  }

  static int totalMedia(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_music(entry)?.mediumCount ?? 0),
    );
  }

  static Map<String, int> countArtists(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(
        entries,
        (music) => [
              if (music.artist != null) music.artist!,
            ]);
  }

  static Map<String, int> countGenres(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(entries, (music) => music.genres);
  }

  static Map<String, int> countFormats(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(
        entries,
        (music) => [
              for (final release in music.releases) ...[
                if (release.releaseType != null) release.releaseType!,
                for (final medium in release.mediums)
                  if (medium.mediumType != null) medium.mediumType!,
              ],
            ]);
  }

  static Map<String, int> countLabels(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(
        entries,
        (music) => [
              for (final release in music.releases)
                if (release.publisher != null) release.publisher!,
            ]);
  }

  static MusicReleaseGroup? _music(LibraryWorkspaceSource entry) {
    final catalog = entry.catalogData;
    return catalog is MusicWorkspaceCatalogData ? catalog.music : null;
  }

  static Map<String, int> _countMany(
    Iterable<LibraryWorkspaceSource> entries,
    Iterable<String> Function(MusicReleaseGroup music) valuesFor,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final music = _music(entry);
      if (music == null) continue;
      final seen = <String>{};
      for (final raw in valuesFor(music)) {
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
