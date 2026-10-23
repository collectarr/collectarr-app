import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/detail/library_workspace_detail_navigation.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/data/game_hardware_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_completeness.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/stats/library_family_stats_page.dart';
import 'package:collectarr_app/features/library/stats/library_stats_charts.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

/// Hardware statistics open as the Hardware tab of the Games family page.
class GameHardwareStatsCapability extends DefaultLibraryStatsCapability
    implements LibraryCollectionStatsContributor {
  const GameHardwareStatsCapability();

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
      GameHardwareCollectionStats(entries: entries);
}

/// The reference Hardware tab: platform, release year and completeness
/// charts with the most valuable and most recent devices.
class GameHardwareCollectionStats extends StatelessWidget {
  const GameHardwareCollectionStats({super.key, required this.entries});
  final List<LibraryWorkspaceContext> entries;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final entry in entries)
        if (GameHardwareLibraryEntryProjection.fromDispatch(
                entry.libraryEntryDispatch)
            case final item?)
          (entry, item)
    ];
    final accent = LibraryAccentScope.accentOf(context);
    final tiers = [
      for (final tier in GameHardwareCompleteness.values) tier.label,
      if (items.any((i) => i.$2.personal.details.completeness == null)) 'N/A',
    ];
    final tierColors = statsSegmentColors(tiers);
    final byPlatform = <String, Map<String, num>>{};
    final byYear = <String, num>{};
    final byTier = <String, num>{};
    final valueByTier = <String, num>{};
    final valueByCurrency = <String?, int>{};
    String? currency;
    for (final (_, item) in items) {
      final platform = item.metadata.platform?.trim() ?? 'Unknown';
      final tier = item.personal.details.completeness?.label ?? 'N/A';
      (byPlatform[platform] ??= {})[tier] =
          (byPlatform[platform]![tier] ?? 0) + 1;
      final year =
          item.metadata.releaseDateParts?.year?.toString() ?? 'Unknown';
      byYear[year] = (byYear[year] ?? 0) + 1;
      byTier[tier] = (byTier[tier] ?? 0) + 1;
      if (item.personal.marketValueCents != null) {
        currency ??= item.personal.currency;
        valueByTier[tier] = (valueByTier[tier] ?? 0) + _value(item);
        valueByCurrency[item.personal.currency] =
            (valueByCurrency[item.personal.currency] ?? 0) + _value(item);
      }
    }
    String count(num value) => '$value hardware';
    String money(num value) => AppFormats.current
        .formatMoney(value.round(), currency ?? AppFormats.current.currency);
    final valuable = [...items.where((i) => _value(i.$2) > 0)]
      ..sort((a, b) => _value(b.$2).compareTo(_value(a.$2)));
    final recent = [...items]..sort((a, b) =>
        (b.$1.addedAt ?? DateTime(0)).compareTo(a.$1.addedAt ?? DateTime(0)));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      StatsSummaryPanel(lines: [
        StatsSummaryLine(fontSize: 18, parts: [
          ('${items.length}', true),
          (' hardware in ', false),
          ('${byPlatform.length}', true),
          (byPlatform.length == 1 ? ' platform' : ' platforms', false),
        ]),
        StatsSummaryLine(fontSize: 16, parts: [
          ('current value: ', false),
          (formatStatsMoneyTotals(valueByCurrency), true),
        ]),
      ]),
      StatsSection(
          title: 'Hardware by Platform',
          child: StatsStackedBarChart(
              values: byPlatform,
              segmentColors: tierColors,
              emptyLabel: 'No hardware',
              valueLabel: count)),
      StatsTwoColumns(sections: [
        StatsSection(
            title: 'Most valuable hardware',
            child: _HardwareList(
                items: valuable.take(5).toList(), showValue: true)),
        StatsSection(
            title: 'Most recent additions',
            child: _HardwareList(items: recent.take(5).toList())),
      ]),
      StatsSection(
          title: 'Hardware by Release Year',
          child: StatsSeriesChart(
              values: byYear,
              accent: accent,
              chronological: true,
              emptyLabel: 'No hardware',
              valueLabel: count)),
      StatsTwoColumns(sections: [
        StatsSection(
            title: 'Completeness',
            child: StatsPieChart(
                values: byTier,
                colorsByLabel: tierColors,
                ranked: false,
                emptyLabel: 'No hardware',
                valueLabel: count)),
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

int _value(GameHardwareLibraryEntry item) =>
    (item.personal.marketValueCents ?? 0) * item.personal.quantity;

class _HardwareList extends StatelessWidget {
  const _HardwareList({required this.items, this.showValue = false});
  final List<(LibraryWorkspaceContext, GameHardwareLibraryEntry)> items;
  final bool showValue;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Text('No hardware');
    return Column(children: [
      for (final (entry, item) in items)
        StatsItemTile(
          onTap: () => openWorkspaceEntryDetails(context, entry),
          image: LibraryCoverImage(
              title: item.metadata.title,
              libraryEntryRef: entry.libraryEntryRef,
              imageUrl: item.metadata.coverImageUrl,
              fallbackAspectRatio: 1,
              borderRadius: 0),
          title: item.metadata.title,
          lines: [
            const SizedBox(height: 14),
            Text(AppFormats.current
                .formatPartialDate(item.metadata.releaseDateParts)),
          ],
          bottom: Row(children: [
            SizedBox(
                width: 18, child: buildPlatformIcon(item.metadata.platform)),
            if (!showValue && item.metadata.platform != null) ...[
              const SizedBox(width: 4),
              Text(item.metadata.platform!,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ]),
          trailing: showValue
              ? StatsValueBadge(AppFormats.current.formatMoney(_value(item),
                  item.personal.currency ?? AppFormats.current.currency))
              : null,
        ),
    ]);
  }
}
