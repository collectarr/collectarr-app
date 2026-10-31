import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/detail/library_workspace_detail_navigation.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_value_summary.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/stats/library_stats_charts.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

/// One reference Games statistics tab: platform, value, release year, genre,
/// completeness and completion charts with the most valuable and most recent
/// games.
class GameCollectionStats extends StatelessWidget {
  const GameCollectionStats({super.key, required this.entries});
  final List<LibraryWorkspaceContext> entries;

  @override
  Widget build(BuildContext context) {
    final games = [
      for (final entry in entries)
        if (GameLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch)
            case final game?)
          (entry, game)
    ];
    final facts = GameCollectionFacts.of([for (final (_, g) in games) g]);
    final accent = LibraryAccentScope.accentOf(context);
    final tierColors = statsSegmentColors(facts.tiers);
    String count(num value) => '$value games';
    String money(num value) =>
        AppFormats.current.formatMoney(value.round(), facts.currency);
    final valuable = [...games.where((g) => _value(g.$2) > 0)]
      ..sort((a, b) => _value(b.$2).compareTo(_value(a.$2)));
    final recent = [...games]..sort((a, b) =>
        (b.$1.addedAt ?? DateTime(0)).compareTo(a.$1.addedAt ?? DateTime(0)));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      StatsSummaryPanel(lines: [
        StatsSummaryLine(fontSize: 18, parts: [
          ('${games.length}', true),
          (games.length == 1 ? ' game in ' : ' games in ', false),
          ('${facts.byPlatform.length}', true),
          (facts.byPlatform.length == 1 ? ' platform' : ' platforms', false),
        ]),
        StatsSummaryLine(fontSize: 16, parts: [
          ('current value: ', false),
          (formatStatsMoneyTotals(facts.valueByCurrency), true),
        ]),
      ]),
      StatsSection(
          title: 'Games by Platform',
          child: StatsStackedBarChart(
              values: facts.byPlatform,
              segmentColors: tierColors,
              emptyLabel: 'No games',
              valueLabel: count)),
      StatsTwoColumns(sections: [
        StatsSection(
            title: 'Most valuable games',
            child:
                _GameList(games: valuable.take(5).toList(), showValue: true)),
        StatsSection(
            title: 'Most recent additions',
            child: _GameList(games: recent.take(5).toList())),
      ]),
      StatsSection(
          title: 'Value per Platform',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            StatsSeriesChart(
                values: facts.valueByPlatform,
                accent: accent,
                emptyLabel: 'No values',
                valueLabel: money,
                axisLabel: money),
            const SizedBox(height: 8),
            StatsSummaryLine(fontSize: 14, parts: [
              ('total value ', false),
              (formatStatsMoneyTotals(facts.valueByCurrency), true),
              (', based on ', false),
              ('${facts.valuedCount}', true),
              (facts.valuedCount == 1 ? ' game' : ' games', false),
            ]),
          ])),
      StatsSection(
          title: 'Games by Release Year',
          child: StatsSeriesChart(
              values: facts.byYear,
              accent: accent,
              chronological: true,
              emptyLabel: 'No games',
              valueLabel: count)),
      StatsSection(
          title: 'Games by Genre',
          child: StatsSeriesChart(
              values: facts.byGenre,
              accent: accent,
              emptyLabel: 'No games',
              valueLabel: count)),
      StatsTwoColumns(sections: [
        StatsSection(
            title: 'Completeness',
            child: StatsPieChart(
                values: facts.byTier,
                colorsByLabel: tierColors,
                ranked: false,
                emptyLabel: 'No games',
                valueLabel: count)),
        StatsSection(
            title: 'Value by Completeness',
            child: StatsPieChart(
                values: facts.valueByTier,
                colorsByLabel: tierColors,
                ranked: false,
                emptyLabel: 'No values',
                valueLabel: money)),
        StatsSection(
            title: 'Games Completed',
            child: StatsPieChart(
                values: {
                  'Completed': facts.completed,
                  'Not completed': games.length - facts.completed,
                },
                colorsByLabel:
                    statsSegmentColors(const ['Completed', 'Not completed']),
                ranked: false,
                emptyLabel: 'No games',
                valueLabel: count)),
      ]),
    ]);
  }
}

int _value(GameLibraryEntry game) =>
    (game.personal.marketValueCents ?? 0) * game.personal.quantity;

/// Counts and value totals behind the Games statistics tab.
final class GameCollectionFacts {
  GameCollectionFacts._({
    required this.tiers,
    required this.byPlatform,
    required this.valueByPlatform,
    required this.byYear,
    required this.byGenre,
    required this.byTier,
    required this.valueByTier,
    required this.valueByCurrency,
    required this.valuedCount,
    required this.completed,
    required this.currency,
  });

  factory GameCollectionFacts.of(List<GameLibraryEntry> games) {
    String tierOf(GameLibraryEntry game) =>
        gameCompletenessOptions
            .where((option) => option.$1 == game.personal.details.completeness)
            .firstOrNull
            ?.$2 ??
        'N/A';
    final tiers = [
      for (final (_, label) in gameCompletenessOptions)
        if (label != 'N/A') label,
      if (games.any((game) => tierOf(game) == 'N/A')) 'N/A',
    ];
    final byPlatform = <String, Map<String, num>>{};
    final valueByPlatform = <String, num>{};
    final byYear = <String, num>{};
    final byGenre = <String, num>{};
    final byTier = <String, num>{};
    final valueByTier = <String, num>{};
    final valueByCurrency = <String?, int>{};
    var valued = 0;
    var completed = 0;
    String? currency;
    for (final game in games) {
      final platform = game.metadata.platforms.firstOrNull?.trim() ?? 'Unknown';
      final tier = tierOf(game);
      final value = _value(game);
      (byPlatform[platform] ??= {})[tier] =
          (byPlatform[platform]![tier] ?? 0) + 1;
      final year =
          game.metadata.releaseDateParts?.year?.toString() ?? 'Unknown';
      byYear[year] = (byYear[year] ?? 0) + 1;
      for (final genre in game.metadata.genres) {
        byGenre[genre] = (byGenre[genre] ?? 0) + 1;
      }
      byTier[tier] = (byTier[tier] ?? 0) + 1;
      if (game.personal.details.completed == true) completed++;
      if (game.personal.marketValueCents != null) {
        valued++;
        currency ??= game.personal.currency;
        valueByPlatform[platform] = (valueByPlatform[platform] ?? 0) + value;
        valueByTier[tier] = (valueByTier[tier] ?? 0) + value;
        valueByCurrency[game.personal.currency] =
            (valueByCurrency[game.personal.currency] ?? 0) + value;
      }
    }
    return GameCollectionFacts._(
      tiers: tiers,
      byPlatform: byPlatform,
      valueByPlatform: valueByPlatform,
      byYear: byYear,
      byGenre: byGenre,
      byTier: byTier,
      valueByTier: valueByTier,
      valueByCurrency: valueByCurrency,
      valuedCount: valued,
      completed: completed,
      currency: currency ?? AppFormats.current.currency,
    );
  }

  /// Completeness labels in reference order; N/A only when used.
  final List<String> tiers;
  final Map<String, Map<String, num>> byPlatform;
  final Map<String, num> valueByPlatform;
  final Map<String, num> byYear;
  final Map<String, num> byGenre;
  final Map<String, num> byTier;
  final Map<String, num> valueByTier;
  final Map<String?, int> valueByCurrency;
  final int valuedCount;
  final int completed;

  /// Currency of the value charts.
  final String currency;
}

/// Reference game rows: cover, title, release date and platform, with the
/// value badge on the most valuable list.
class _GameList extends StatelessWidget {
  const _GameList({required this.games, this.showValue = false});
  final List<(LibraryWorkspaceContext, GameLibraryEntry)> games;
  final bool showValue;
  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) return const Text('No games');
    return Column(children: [
      for (final (entry, game) in games)
        StatsItemTile(
          onTap: () => openWorkspaceEntryDetails(context, entry),
          image: LibraryCoverImage(
              title: game.metadata.title,
              libraryEntryRef: entry.libraryEntryRef,
              imageUrl: game.metadata.coverImageUrl,
              fallbackAspectRatio: 1,
              borderRadius: 0),
          title: game.metadata.title,
          lines: [
            const SizedBox(height: 14),
            Text(AppFormats.current
                .formatPartialDate(game.metadata.releaseDateParts)),
          ],
          bottom: _platformLine(game.metadata.platforms.firstOrNull,
              showName: !showValue),
          trailing: showValue
              ? StatsValueBadge(AppFormats.current.formatMoney(_value(game),
                  game.personal.currency ?? AppFormats.current.currency))
              : null,
        ),
    ]);
  }
}

Widget _platformLine(String? platform, {required bool showName}) =>
    Row(children: [
      buildPlatformIcon(platform),
      if (showName && platform != null) ...[
        const SizedBox(width: 6),
        Text(platform, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ]);
