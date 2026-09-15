import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
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
    final releaseGroups = totalReleaseGroups(state.entries);
    final releases = totalReleases(state.entries);
    final ownedCopies = totalOwnedCopies(state.entries);
    final signedCopies = totalSignedCopies(state.entries);
    return [
      if (releaseGroups > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.library_music_outlined,
          label: 'Release groups',
          value: releaseGroups.toString(),
        ),
      if (releases > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.album_outlined,
          label: 'Releases',
          value: releases.toString(),
        ),
      if (ownedCopies > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.inventory_2_outlined,
          label: 'Owned copies',
          value: ownedCopies.toString(),
        ),
      if (signedCopies > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.draw_outlined,
          label: 'Signed copies',
          value: signedCopies.toString(),
        ),
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
      LibraryStatsRankedCard(
        title: 'Top Artists',
        values: countArtists(state.entries),
      ),
      LibraryStatsRankedCard(
        title: 'Top Labels',
        values: countLabels(state.entries),
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

  static int totalReleaseGroups(Iterable<LibraryWorkspaceSource> entries) {
    return entries.where((entry) => _music(entry) != null).length;
  }

  static int totalReleases(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_music(entry)?.releaseCount ?? 0),
    );
  }

  static int totalOwnedCopies(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (entry.ownedSummary?.quantity ?? 0),
    );
  }

  static int totalMedia(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_music(entry)?.mediumCount ?? 0),
    );
  }

  static int totalSignedCopies(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) {
        final owned = MusicOwnedItemProjection.fromDispatch(
          entry.ownedItemDispatch,
        );
        return total +
            (owned?.details.signedBy?.trim().isNotEmpty == true
                ? owned!.quantity
                : 0);
      },
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
