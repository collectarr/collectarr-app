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
    final boardgame = dto.boardgame;
    final metadata = dto.metadata;
    final sessionStats = ref
        .watch(boardGamePlayStatsProvider(BoardGameCatalogItemId(boardgame.id)))
        .asData
        ?.value;
    final playCount = sessionStats?.playCount;
    final lastPlayed = sessionStats?.lastPlayed;
    final facts = <LibraryDetailField>[
      if (metadata.minPlayers != null ||
          metadata.maxPlayers != null ||
          metadata.bestPlayers != null)
        LibraryDetailField(label: 'Players', value: _playersLabel(dto)),
      if (metadata.minPlaytimeMinutes != null ||
          metadata.maxPlaytimeMinutes != null)
        LibraryDetailField(
          label: 'Play time',
          value: _playtimeLabel(dto),
        ),
      if (metadata.minimumAge != null)
        LibraryDetailField(label: 'Age', value: '${metadata.minimumAge}+'),
      if (metadata.bggRank != null)
        LibraryDetailField(label: 'BGG rank', value: '#${metadata.bggRank}'),
      if (metadata.bggRating != null)
        LibraryDetailField(
            label: 'BGG rating', value: metadata.bggRating!.toStringAsFixed(2)),
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
    ];

    final chipSections = <Widget>[
      if (boardgame.mechanics.isNotEmpty)
        LibraryDetailChipGroupWidget(
          label: 'Mechanics',
          values: boardgame.mechanics,
        ),
      if (boardgame.categories.isNotEmpty) ...[
        if (boardgame.mechanics.isNotEmpty) const SizedBox(height: 8),
        LibraryDetailChipGroupWidget(
          label: 'Categories',
          values: boardgame.categories,
        ),
      ],
      if (boardgame.expansions.isNotEmpty) ...[
        if (boardgame.mechanics.isNotEmpty || boardgame.categories.isNotEmpty)
          const SizedBox(height: 8),
        LibraryDetailChipGroupWidget(
          label: 'Expansions',
          values: boardgame.expansions,
        ),
      ],
      if (sessionStats?.mostPlayedWith.isNotEmpty == true) ...[
        if (boardgame.mechanics.isNotEmpty ||
            boardgame.categories.isNotEmpty ||
            boardgame.expansions.isNotEmpty)
          const SizedBox(height: 8),
        LibraryDetailChipGroupWidget(
          label: 'Most played with',
          values: sessionStats!.mostPlayedWith,
        ),
      ],
      if (sessionStats?.winStats.isNotEmpty == true) ...[
        if (boardgame.mechanics.isNotEmpty ||
            boardgame.categories.isNotEmpty ||
            boardgame.expansions.isNotEmpty ||
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

String _playersLabel(BoardGameWorkspaceDto dto) {
  final minPlayers = dto.minPlayers;
  final maxPlayers = dto.maxPlayers;
  final bestPlayers = dto.bestPlayers;
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

String _playtimeLabel(BoardGameWorkspaceDto dto) {
  final minMinutes = dto.minPlaytimeMinutes;
  final maxMinutes = dto.maxPlaytimeMinutes;
  if (minMinutes != null && maxMinutes != null && minMinutes != maxMinutes) {
    return '$minMinutes–$maxMinutes min';
  }
  return '${minMinutes ?? maxMinutes} min';
}

String _formatDate(DateTime value) {
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
