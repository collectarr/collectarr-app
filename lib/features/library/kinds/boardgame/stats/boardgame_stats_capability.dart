import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_play_session_providers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_play_session.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoardGameStatsCapability implements LibraryStatsCapability {
  const BoardGameStatsCapability();

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
    final averageRating = averageBggRating(state.entries);
    final bestRank = bestBggRank(state.entries);
    return [
      if (averageRating != null)
        LibraryStatsTileDescriptor(
          icon: Icons.star,
          label: 'Avg. BGG rating',
          value: averageRating.toStringAsFixed(1),
        ),
      if (bestRank != null)
        LibraryStatsTileDescriptor(
          icon: Icons.leaderboard_outlined,
          label: 'Best BGG rank',
          value: '#$bestRank',
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
        title: 'Top Mechanics',
        values: countMechanics(state.entries),
      ),
      LibraryStatsRankedCard(
        title: 'Top Categories',
        values: countCategories(state.entries),
      ),
      LibraryStatsRankedCard(
        title: 'Top Designers',
        values: countDesigners(state.entries),
      ),
      BoardGamePlayStatsCard(
        mediaIds: [
          for (final entry in state.entries) BoardGameMediaId(entry.itemId),
        ],
      ),
    ];
  }

  static double? averageBggRating(Iterable<ShelfEntry> entries) {
    var total = 0.0;
    var count = 0;
    for (final entry in entries) {
      final rating = _metadata(entry)?.bggRating;
      if (rating == null) continue;
      total += rating;
      count++;
    }
    return count == 0 ? null : total / count;
  }

  static int? bestBggRank(Iterable<ShelfEntry> entries) {
    int? best;
    for (final entry in entries) {
      final rank = _metadata(entry)?.bggRank;
      if (rank == null || rank <= 0) continue;
      if (best == null || rank < best) best = rank;
    }
    return best;
  }

  static Map<String, int> countMechanics(Iterable<ShelfEntry> entries) {
    return _countMany(entries, (metadata) => metadata.mechanics);
  }

  static Map<String, int> countCategories(Iterable<ShelfEntry> entries) {
    return _countMany(entries, (metadata) => metadata.categories);
  }

  static Map<String, int> countDesigners(Iterable<ShelfEntry> entries) {
    return _countMany(entries, (metadata) => metadata.designers);
  }

  static BoardGameMetadata? _metadata(ShelfEntry entry) {
    final metadata = entry.catalogItem?.kindMetadata;
    return metadata is BoardGameMetadata ? metadata : null;
  }

  static Map<String, int> _countMany(
    Iterable<ShelfEntry> entries,
    Iterable<String> Function(BoardGameMetadata metadata) valuesFor,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final metadata = _metadata(entry);
      if (metadata == null) continue;
      final seen = <String>{};
      for (final value in valuesFor(metadata)) {
        final normalized = value.trim();
        if (normalized.isEmpty) continue;
        final key = normalized.toLowerCase();
        if (!seen.add(key)) continue;
        counts[normalized] = (counts[normalized] ?? 0) + 1;
      }
    }
    return counts;
  }
}

class BoardGamePlayStatsCard extends ConsumerWidget {
  const BoardGamePlayStatsCard({
    super.key,
    required this.mediaIds,
  });

  final List<BoardGameMediaId> mediaIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(boardGameAllPlaySessionsProvider);
    return sessions.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (allSessions) {
        final ids = mediaIds.toSet();
        final scopedSessions = allSessions
            .where((session) =>
                ids.contains(BoardGameMediaId(session.boardGameId)))
            .toList(growable: false);
        if (scopedSessions.isEmpty) return const SizedBox.shrink();

        final stats = BoardGamePlayStats.fromSessions(scopedSessions);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LibraryStatsTile(
                  icon: Icons.casino_outlined,
                  label: 'Plays',
                  value: stats.playCount.toString(),
                ),
                if (stats.averageDurationMinutes != null)
                  LibraryStatsTile(
                    icon: Icons.timer_outlined,
                    label: 'Avg. time',
                    value: '${stats.averageDurationMinutes!.round()} min',
                  ),
              ],
            ),
            if (stats.winStats.isNotEmpty) ...[
              const SizedBox(height: 8),
              LibraryStatsRankedCard(
                title: 'Wins by Player',
                values: stats.winStats,
              ),
            ],
          ],
        );
      },
    );
  }
}
