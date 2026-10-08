import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Music-specific collection aggregates: tracks, formats, artists, and labels.
final class MusicStatsCapability implements LibraryStatsCapability {
  const MusicStatsCapability();

  @override
  LibraryEntryFinancialSummary buildEntryFinancialSummary(
      LibraryWorkspaceContext entry) {
    return LibraryEntryFinancialSummary(
      pricePaidCents: entry.pricePaidCents,
      sellPriceCents: entry.sellPriceCents,
      currency: entry.currency,
    );
  }

  @override
  LibraryStatsMetadataProjection? buildMetadataProjection(
      LibraryWorkspaceContext entry) {
    final music = _music(entry);
    if (music == null) return null;
    final secondary = music.publisher?.trim();
    final releaseYear =
        music.releaseDate?.year ?? music.originalReleaseDate?.year;
    final inlineFacts = <LibraryStatsInlineFact>[];
    final tracksCount = music.trackCount;
    if (tracksCount > 0) {
      inlineFacts.add(LibraryStatsInlineFact(
        icon: Icons.music_note,
        text: '$tracksCount tracks',
      ));
      var durationSec = 0;
      for (final track in music.tracks) {
        if (track.durationMs != null && track.durationMs! > 0) {
          durationSec += (track.durationMs! / 1000).round();
        }
      }
      if (durationSec > 0) {
        final minutes = durationSec ~/ 60;
        final seconds = durationSec % 60;
        inlineFacts.add(LibraryStatsInlineFact(
          text: '$minutes:${seconds.toString().padLeft(2, '0')}',
        ));
      }
    }
    return LibraryStatsMetadataProjection(
      primaryGroup: music.artist?.trim(),
      secondaryGroup: secondary,
      format: music.formatSummary?.trim(),
      releaseYear: releaseYear,
      genres: music.genres,
      hasCover: music.coverImageUrl?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          music.formatSummary?.trim().isNotEmpty == true,
      hasReleaseDate:
          music.originalReleaseDate != null || music.releaseDate != null,
      inlineFacts: inlineFacts,
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

  @override
  Widget? buildCustomHeader(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) {
    final albums = totalCatalogItems(state.entries);
    final artists = countArtists(state.entries).length;
    final discs = totalMedia(state.entries);
    final tracks = totalTracks(state.entries);
    final runtimeSec = totalRuntimeSeconds(state.entries);
    final runtimeFormatted = formatRuntime(runtimeSec);
    final palette = appPalette(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 19,
                color: palette.textPrimary,
              ),
              children: [
                TextSpan(
                  text: '$albums ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: 'albums and '),
                TextSpan(
                  text: '$artists ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: 'Artists'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 15,
                color: palette.textSecondary,
              ),
              children: [
                TextSpan(
                  text: '$discs ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
                const TextSpan(text: 'discs, '),
                TextSpan(
                  text: '$tracks ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
                const TextSpan(text: 'tracks / total runtime: '),
                TextSpan(
                  text: runtimeFormatted,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget? buildCustomStatsPage(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) =>
      null;

  static int totalRuntimeSeconds(Iterable<LibraryWorkspaceContext> entries) {
    var totalSeconds = 0;
    for (final entry in entries) {
      final music = _music(entry);
      if (music == null) continue;
      for (final disc in music.discs) {
        for (final track in disc.tracks) {
          if (!track.isHeader &&
              track.durationMs != null &&
              track.durationMs! > 0) {
            totalSeconds += (track.durationMs! / 1000).round();
          }
        }
      }
    }
    return totalSeconds;
  }

  static String formatRuntime(int totalSeconds) {
    if (totalSeconds <= 0) return '0 minutes';
    final duration = Duration(seconds: totalSeconds);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final parts = <String>[];
    if (days > 0) parts.add('$days day${days == 1 ? '' : 's'}');
    if (hours > 0 || days > 0) parts.add('$hours hour${hours == 1 ? '' : 's'}');
    parts.add('$minutes minute${minutes == 1 ? '' : 's'}');
    return parts.join(', ');
  }

  static int totalListens(Iterable<LibraryWorkspaceContext> entries) {
    return entries.fold<int>(
      0,
      (total, entry) =>
          total + (_catalog(entry)?.listeningSummary?.totalListenCount ?? 0),
    );
  }

  static Map<String, int> countMostListenedItems(
    Iterable<LibraryWorkspaceContext> entries,
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
    Iterable<LibraryWorkspaceContext> entries,
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
    Iterable<LibraryWorkspaceContext> entries,
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

  static int totalTracks(Iterable<LibraryWorkspaceContext> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_music(entry)?.trackCount ?? 0),
    );
  }

  static int totalCatalogItems(Iterable<LibraryWorkspaceContext> entries) {
    return entries.where((entry) => _music(entry) != null).length;
  }

  static int totalEntryCopies(Iterable<LibraryWorkspaceContext> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (entry.libraryEntrySummary == null ? 0 : 1),
    );
  }

  static int totalMedia(Iterable<LibraryWorkspaceContext> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_music(entry)?.discs.length ?? 0),
    );
  }

  static int totalSignedCopies(Iterable<LibraryWorkspaceContext> entries) {
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
      Iterable<LibraryWorkspaceContext> entries) {
    return _countMany(
        entries,
        (music) => [
              if (music.artist != null) music.artist!,
            ]);
  }

  static Map<String, int> countGenres(
      Iterable<LibraryWorkspaceContext> entries) {
    return _countMany(entries, (music) => music.genres);
  }

  static Map<String, int> countFormats(
      Iterable<LibraryWorkspaceContext> entries) {
    return _countMany(
      entries,
      (music) => [if (music.formatSummary != null) music.formatSummary!],
    );
  }

  static Map<String, int> countLabels(
      Iterable<LibraryWorkspaceContext> entries) {
    return _countMany(
      entries,
      (music) => [if (music.publisher != null) music.publisher!],
    );
  }

  static MusicAlbum? _music(LibraryWorkspaceContext entry) {
    return _catalog(entry)?.music;
  }

  static MusicWorkspaceData? _catalog(
    LibraryWorkspaceContext entry,
  ) {
    final catalog = entry.kindPresentationData;
    return catalog is MusicWorkspaceData ? catalog : null;
  }

  static Map<String, int> _countMany(
    Iterable<LibraryWorkspaceContext> entries,
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
