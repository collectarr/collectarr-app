import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/detail/library_workspace_detail_navigation.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/data/game_toy_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_completeness.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/stats/library_family_stats_page.dart';
import 'package:collectarr_app/features/library/stats/library_stats_charts.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

/// Toy statistics open as the Toys tab of the Games family page.
class GameToyStatsCapability extends DefaultLibraryStatsCapability
    implements LibraryCollectionStatsContributor {
  const GameToyStatsCapability();

  @override
  Widget? buildCustomStatsPage(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) =>
      LibraryFamilyStatsPage(type: type, state: state);

  @override
  Widget buildCollectionStats(
          BuildContext context, List<LibraryWorkspaceContext> entries) =>
      GameToyCollectionStats(entries: entries);
}

/// The reference Toys tab: type, release year and completeness charts with
/// the most valuable and most recent toys.
class GameToyCollectionStats extends StatelessWidget {
  const GameToyCollectionStats({super.key, required this.entries});
  final List<LibraryWorkspaceContext> entries;

  @override
  Widget build(BuildContext context) {
    final toys = [
      for (final entry in entries)
        if (GameToyLibraryEntryProjection.fromDispatch(
                entry.libraryEntryDispatch)
            case final toy?)
          (entry, toy)
    ];
    final accent = LibraryAccentScope.accentOf(context);
    final tierColors = statsSegmentColors(
        [for (final tier in GameToyCompleteness.values) tier.label]);
    final byType = <String, num>{};
    final byTypeAndTier = <String, Map<String, num>>{};
    final byYear = <String, num>{};
    final valueByTier = <String, num>{};
    final valueByCurrency = <String?, int>{};
    String? currency;
    for (final (_, toy) in toys) {
      final type = toy.metadata.toyType?.trim() ?? 'Unknown';
      final tier = toy.personal.details.completeness.label;
      byType[type] = (byType[type] ?? 0) + 1;
      (byTypeAndTier[type] ??= {})[tier] =
          (byTypeAndTier[type]![tier] ?? 0) + 1;
      final year = toy.metadata.releaseDateParts?.year?.toString() ?? 'Unknown';
      byYear[year] = (byYear[year] ?? 0) + 1;
      if (toy.personal.marketValueCents != null) {
        currency ??= toy.personal.currency;
        valueByTier[tier] = (valueByTier[tier] ?? 0) + _value(toy);
        valueByCurrency[toy.personal.currency] =
            (valueByCurrency[toy.personal.currency] ?? 0) + _value(toy);
      }
    }
    String count(num value) => value == 1 ? '$value toy' : '$value toys';
    String money(num value) => AppFormats.current
        .formatMoney(value.round(), currency ?? AppFormats.current.currency);
    final valuable = [...toys.where((t) => _value(t.$2) > 0)]
      ..sort((a, b) => _value(b.$2).compareTo(_value(a.$2)));
    final recent = [...toys]..sort((a, b) =>
        (b.$1.addedAt ?? DateTime(0)).compareTo(a.$1.addedAt ?? DateTime(0)));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      StatsSummaryPanel(lines: [
        StatsSummaryLine(fontSize: 18, parts: [
          ('${toys.length}', true),
          (toys.length == 1 ? ' toy in ' : ' toys in ', false),
          ('${byType.length}', true),
          (byType.length == 1 ? ' type' : ' types', false),
        ]),
        StatsSummaryLine(fontSize: 16, parts: [
          ('current value: ', false),
          (formatStatsMoneyTotals(valueByCurrency), true),
        ]),
      ]),
      StatsTwoColumns(sections: [
        StatsSection(
            title: 'Most valuable toys',
            child: _ToyList(toys: valuable.take(5).toList(), showValue: true)),
        StatsSection(
            title: 'Most recent additions',
            child: _ToyList(toys: recent.take(5).toList())),
        StatsSection(
            title: 'Toys by Type',
            child: StatsPieChart(
                values: byType, emptyLabel: 'No toys', valueLabel: count)),
        StatsSection(
            title: 'Toys by Type',
            child: StatsStackedBarChart(
                values: byTypeAndTier,
                segmentColors: tierColors,
                emptyLabel: 'No toys',
                valueLabel: count)),
      ]),
      StatsSection(
          title: 'Toys by Release Year',
          child: StatsSeriesChart(
              values: byYear,
              accent: accent,
              chronological: true,
              emptyLabel: 'No toys',
              valueLabel: count)),
      StatsTwoColumns(sections: [
        StatsSection(
            title: 'Value by Completeness',
            child: StatsPieChart(
                values: valueByTier,
                colorsByLabel: tierColors,
                ranked: false,
                emptyLabel: 'No values',
                valueLabel: money)),
      ]),
    ]);
  }
}

int _value(GameToyLibraryEntry toy) =>
    (toy.personal.marketValueCents ?? 0) * toy.personal.quantity;

class _ToyList extends StatelessWidget {
  const _ToyList({required this.toys, this.showValue = false});
  final List<(LibraryWorkspaceContext, GameToyLibraryEntry)> toys;
  final bool showValue;
  @override
  Widget build(BuildContext context) {
    if (toys.isEmpty) return const Text('No toys');
    return Column(children: [
      for (final (entry, toy) in toys)
        StatsItemTile(
          onTap: () => openWorkspaceEntryDetails(context, entry),
          image: LibraryCoverImage(
              title: toy.metadata.title,
              libraryEntryRef: entry.libraryEntryRef,
              imageUrl: toy.metadata.coverImageUrl,
              fallbackAspectRatio: 1,
              borderRadius: 0),
          title: toy.metadata.title,
          lines: [
            const SizedBox(height: 14),
            Text(AppFormats.current
                .formatPartialDate(toy.metadata.releaseDateParts)),
          ],
          trailing: showValue
              ? StatsValueBadge(AppFormats.current.formatMoney(_value(toy),
                  toy.personal.currency ?? AppFormats.current.currency))
              : null,
        ),
    ]);
  }
}
