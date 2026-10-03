import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

/// Music-specific collection aggregates: tracks, formats, artists, and labels.
final class MusicStatsCapability implements LibraryStatsCapability {
  const MusicStatsCapability();

  @override
  LibraryEntryFinancialSummary buildEntryFinancialSummary(
      LibraryWorkspaceSource entry) {
    return LibraryEntryFinancialSummary(
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
    if (catalog == null || music == null) return null;
    final secondary = music.publisher?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: music.artist?.trim(),
      secondaryGroup: secondary,
      hasCover: catalog.coverImageUrl?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          music.mediums.any(
            (medium) => medium.mediumType?.trim().isNotEmpty == true,
          ),
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
    final catalogItems = totalCatalogItems(state.entries);
    final libraryEntries = totalEntryCopies(state.entries);
    final signedCopies = totalSignedCopies(state.entries);
    final listens = totalListens(state.entries);
    return [
      if (catalogItems > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.library_music_outlined,
          label: 'Catalog Items',
          value: catalogItems.toString(),
        ),
      if (libraryEntries > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.inventory_2_outlined,
          label: 'Collection items',
          value: libraryEntries.toString(),
        ),
      if (signedCopies > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.draw_outlined,
          label: 'Signed items',
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
      if (listens > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.headphones_outlined,
          label: 'Listens',
          value: listens.toString(),
        ),
    ];
  }

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) {
    final mostListenedItems = countMostListenedItems(state.entries);
    final listeningByMonth = countListeningByMonth(state.entries);
    final neverListened = countNeverListenedItems(state.entries);
    return [
      LibraryStatsRankedCard(
        title: 'Top Genres',
        values: countGenres(state.entries),
      ),
      LibraryStatsDistributionCard(
        title: 'Formats',
        values: countFormats(state.entries),
      ),
      if (mostListenedItems.isNotEmpty)
        LibraryStatsRankedCard(
          title: 'Most Listened Albums',
          values: mostListenedItems,
        ),
      if (listeningByMonth.isNotEmpty)
        LibraryStatsDistributionCard(
          title: 'Listening by Month',
          values: listeningByMonth,
        ),
      if (neverListened.isNotEmpty)
        LibraryStatsRankedCard(
          title: 'Never Listened Albums',
          values: neverListened,
        ),
    ];
  }

  static int totalListens(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) =>
          total + (_catalog(entry)?.listeningSummary?.totalListenCount ?? 0),
    );
  }

  static Map<String, int> countMostListenedItems(
    Iterable<LibraryWorkspaceSource> entries,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final catalog = _catalog(entry);
      final summary = catalog?.listeningSummary;
      if (catalog == null || summary == null || summary.totalListenCount <= 0) {
        continue;
      }
      counts[catalog.music.title] =
          (counts[catalog.music.title] ?? 0) + summary.totalListenCount;
    }
    return counts;
  }

  static Map<String, int> countListeningByMonth(
    Iterable<LibraryWorkspaceSource> entries,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final summary = _catalog(entry)?.listeningSummary;
      if (summary == null) continue;
      for (final event in summary.recentEvents) {
        final month = '${event.listenedAt.year.toString().padLeft(4, '0')}-'
            '${event.listenedAt.month.toString().padLeft(2, '0')}';
        counts[month] = (counts[month] ?? 0) + 1;
      }
    }
    return counts;
  }

  static Map<String, int> countNeverListenedItems(
    Iterable<LibraryWorkspaceSource> entries,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final catalog = _catalog(entry);
      final summary = catalog?.listeningSummary;
      if (catalog == null || summary == null || summary.totalListenCount > 0) {
        continue;
      }
      counts[catalog.music.title] = (counts[catalog.music.title] ?? 0) + 1;
    }
    return counts;
  }

  static int totalTracks(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_music(entry)?.trackCount ?? 0),
    );
  }

  static int totalCatalogItems(Iterable<LibraryWorkspaceSource> entries) {
    return entries.where((entry) => _music(entry) != null).length;
  }

  static int totalEntryCopies(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (entry.libraryEntrySummary == null ? 0 : 1),
    );
  }

  static int totalMedia(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_music(entry)?.mediums.length ?? 0),
    );
  }

  static int totalSignedCopies(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) {
        final personalState = MusicLibraryEntryProjection.fromDispatch(
          entry.libraryEntryDispatch,
        );
        return total +
            (personalState?.personal.details.signedBy?.trim().isNotEmpty == true
                ? 1
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
        if (music.releaseType != null) music.releaseType!,
        for (final medium in music.mediums)
          if (medium.mediumType != null) medium.mediumType!,
      ],
    );
  }

  static Map<String, int> countLabels(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(
      entries,
      (music) => [if (music.publisher != null) music.publisher!],
    );
  }

  static MusicAlbum? _music(LibraryWorkspaceSource entry) {
    return _catalog(entry)?.music;
  }

  static MusicWorkspaceCatalogData? _catalog(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    return catalog is MusicWorkspaceCatalogData ? catalog : null;
  }

  static Map<String, int> _countMany(
    Iterable<LibraryWorkspaceSource> entries,
    Iterable<String> Function(MusicAlbum music) valuesFor,
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
