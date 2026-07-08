import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class BoardGamePlayStatsSection extends StatelessWidget {
  const BoardGamePlayStatsSection({
    super.key,
    required this.request,
  });

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final entry = request.entry;
    final boardGameEntry =
        entry is BoardGameWorkspaceEntry ? entry : null;
    final work = boardGameEntry?.boardGameWork;
    if (work == null) {
      return const SizedBox.shrink();
    }

    final edition = _primaryEdition(work);
    final stats = work.playStats;
    final facts = <LibraryDetailField>[
      if (edition?.minPlayers != null ||
          edition?.maxPlayers != null ||
          edition?.bestPlayers != null)
        LibraryDetailField(label: 'Players', value: _playersLabel(edition)),
      if (edition?.playingTimeMinutes != null)
        LibraryDetailField(label: 'Play time', value: '${edition!.playingTimeMinutes} min'),
      if (edition?.minAge != null)
        LibraryDetailField(label: 'Age', value: '${edition!.minAge}+'),
      if (stats?.bggRank != null)
        LibraryDetailField(label: 'BGG rank', value: '#${stats!.bggRank}'),
      if (stats?.bggRating != null)
        LibraryDetailField(label: 'BGG rating', value: stats!.bggRating!.toStringAsFixed(2)),
      if (stats?.playCount != null)
        LibraryDetailField(label: 'Play count', value: stats!.playCount.toString()),
      if (stats?.lastPlayed != null)
        LibraryDetailField(label: 'Last played', value: _formatDate(stats!.lastPlayed!)),
      if (stats?.favoritePlayerCount != null)
        LibraryDetailField(label: 'Favorite players', value: stats!.favoritePlayerCount.toString()),
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
      if (stats?.playerStats.isNotEmpty == true) ...[
        if (work.mechanics.isNotEmpty ||
            work.categories.isNotEmpty ||
            work.expansions.isNotEmpty)
          const SizedBox(height: 8),
        LibraryDetailChipGroupWidget(
          label: 'Player stats',
          values: [
            for (final stat in stats!.playerStats) stat.toSummary(),
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
    return bestPlayers == null ? '$minPlayers' : '$minPlayers (best $bestPlayers)';
  }
  if (maxPlayers != null) {
    return bestPlayers == null ? '$maxPlayers' : '$maxPlayers (best $bestPlayers)';
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


