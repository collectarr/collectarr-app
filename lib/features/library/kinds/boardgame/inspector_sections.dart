import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoardGamePlayStatsSection extends ConsumerWidget {
  const BoardGamePlayStatsSection({
    super.key,
    required this.request,
  });

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dto = request.item.dto;
    if (dto is! BoardGameWorkspaceDto) {
      return const SizedBox.shrink();
    }
    final work = dto.boardgame;

    final edition = _primaryEdition(work);
    final stats = work.playStats;
    final sessionStats = ref
        .watch(boardGamePlayStatsProvider(BoardGameMediaId(work.id)))
        .asData
        ?.value;
    final playCount = sessionStats?.playCount ?? stats?.playCount;
    final lastPlayed = sessionStats?.lastPlayed ?? stats?.lastPlayed;
    final facts = <LibraryDetailField>[
      if (edition?.minPlayers != null ||
          edition?.maxPlayers != null ||
          edition?.bestPlayers != null)
        LibraryDetailField(label: 'Players', value: _playersLabel(edition)),
      if (edition?.playingTimeMinutes != null)
        LibraryDetailField(
            label: 'Play time', value: '${edition!.playingTimeMinutes} min'),
      if (edition?.minAge != null)
        LibraryDetailField(label: 'Age', value: '${edition!.minAge}+'),
      if (stats?.bggRank != null)
        LibraryDetailField(label: 'BGG rank', value: '#${stats!.bggRank}'),
      if (stats?.bggRating != null)
        LibraryDetailField(
            label: 'BGG rating', value: stats!.bggRating!.toStringAsFixed(2)),
      if (playCount != null && playCount > 0)
        LibraryDetailField(label: 'Play count', value: playCount.toString()),
      if (lastPlayed != null)
        LibraryDetailField(
            label: 'Last played', value: _formatDate(lastPlayed)),
      if (sessionStats?.averageDurationMinutes != null)
        LibraryDetailField(
          label: 'Average duration',
          value: '${sessionStats!.averageDurationMinutes!.round()} min',
        ),
      if (stats?.favoritePlayerCount != null)
        LibraryDetailField(
            label: 'Favorite players',
            value: stats!.favoritePlayerCount.toString()),
    ];

    final chipSections = <Widget>[
      if (work.mechanics.isNotEmpty)
        LibraryDetailChipGroupWidget(
          label: 'Mechanics',
          values: work.mechanics,
        ),
      if (work.categories.isNotEmpty) ...[
        if (work.mechanics.isNotEmpty) const SizedBox(height: 8),
        LibraryDetailChipGroupWidget(
          label: 'Categories',
          values: work.categories,
        ),
      ],
      if (work.expansions.isNotEmpty) ...[
        if (work.mechanics.isNotEmpty || work.categories.isNotEmpty)
          const SizedBox(height: 8),
        LibraryDetailChipGroupWidget(
          label: 'Expansions',
          values: work.expansions,
        ),
      ],
      if (stats?.playerStats?.isNotEmpty == true) ...[
        if (work.mechanics.isNotEmpty ||
            work.categories.isNotEmpty ||
            work.expansions.isNotEmpty)
          const SizedBox(height: 8),
        LibraryDetailChipGroupWidget(
          label: 'Player stats',
          values: [stats!.playerStats!],
        ),
      ],
      if (sessionStats?.mostPlayedWith.isNotEmpty == true) ...[
        if (work.mechanics.isNotEmpty ||
            work.categories.isNotEmpty ||
            work.expansions.isNotEmpty ||
            stats?.playerStats?.isNotEmpty == true)
          const SizedBox(height: 8),
        LibraryDetailChipGroupWidget(
          label: 'Most played with',
          values: sessionStats!.mostPlayedWith,
        ),
      ],
      if (sessionStats?.winStats.isNotEmpty == true) ...[
        if (work.mechanics.isNotEmpty ||
            work.categories.isNotEmpty ||
            work.expansions.isNotEmpty ||
            stats?.playerStats?.isNotEmpty == true ||
            sessionStats!.mostPlayedWith.isNotEmpty)
          const SizedBox(height: 8),
        LibraryDetailChipGroupWidget(
          label: 'Wins',
          values: [
            for (final entry in sessionStats!.winStats.entries)
              '${entry.key}: ${entry.value}',
          ],
        ),
      ],
    ];

    if (facts.isEmpty && chipSections.isEmpty) {
      return const SizedBox.shrink();
    }

    return LibraryDetailSection(
      title: 'Play stats',
      accentColor: request.accent,
      children: [
        if (facts.isNotEmpty) LibraryDetailFieldTable(fields: facts),
        if (chipSections.isNotEmpty) ...[
          if (facts.isNotEmpty) const SizedBox(height: 8),
          ...chipSections,
        ],
      ],
    );
  }
}

BoardGameEdition? _primaryEdition(BoardGameWork work) {
  return work.editions.isEmpty ? null : work.editions.first;
}

String _playersLabel(BoardGameEdition? edition) {
  if (edition == null) {
    return 'Players';
  }
  final minPlayers = edition.minPlayers;
  final maxPlayers = edition.maxPlayers;
  final bestPlayers = edition.bestPlayers;
  if (minPlayers != null && maxPlayers != null && minPlayers != maxPlayers) {
    final label = '$minPlayers-$maxPlayers';
    return bestPlayers == null ? label : '$label (best $bestPlayers)';
  }
  if (minPlayers != null) {
    return bestPlayers == null
        ? '$minPlayers'
        : '$minPlayers (best $bestPlayers)';
  }
  if (maxPlayers != null) {
    return bestPlayers == null
        ? '$maxPlayers'
        : '$maxPlayers (best $bestPlayers)';
  }
  if (bestPlayers != null) {
    return 'Best $bestPlayers';
  }
  return 'Players';
}

String _formatDate(DateTime value) {
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
