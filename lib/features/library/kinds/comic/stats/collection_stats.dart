import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/detail/workspace_detail_navigation.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';
import 'package:collectarr_app/features/library/stats/charts.dart';
import 'package:collectarr_app/features/library/workspace/entry/context.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

const _noKey = 'No';
const _keySegments = {
  _noKey: Color(0xFF555555),
  'Minor Keys': Color(0xFF0A7FA8),
  'Major Keys': Color(0xFFF0B429),
  'Trivia': Color(0xFFAAAAAA),
};

/// One reference Comics statistics tab: totals, the series, key, publisher,
/// purchase price, grade, year, creator and character charts, and the most
/// recent and most valuable comics.
class ComicCollectionStats extends StatelessWidget {
  const ComicCollectionStats({super.key, required this.entries});
  final List<LibraryWorkspaceContext> entries;

  @override
  Widget build(BuildContext context) {
    final comics = [
      for (final entry in entries)
        if (ComicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch)
            case final personal?)
          if (entry.kindPresentationData case final ComicWorkspaceData data)
            (entry: entry, personal: personal, comic: data.comic)
    ];
    final facts = ComicCollectionFacts.of([
      for (final comic in comics) (comic.personal, comic.comic),
    ]);
    final accent = LibraryAccentScope.accentOf(context);
    String count(num value) => '$value ${value == 1 ? 'comic' : 'comics'}';
    String money(num value) =>
        AppFormats.current.formatMoney(value.round(), facts.currency);
    StatsSeriesChart bars(Map<String, num> values) => StatsSeriesChart(
        values: values,
        accent: accent,
        emptyLabel: 'No comics',
        valueLabel: count);
    final recent = [...comics]..sort((a, b) => (b.entry.addedAt ?? DateTime(0))
        .compareTo(a.entry.addedAt ?? DateTime(0)));
    final valuable = [
      ...comics.where((c) => (c.personal.personal.marketValueCents ?? 0) > 0)
    ]..sort((a, b) => b.personal.personal.marketValueCents!
        .compareTo(a.personal.personal.marketValueCents!));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      StatsSection(
          title: 'Totals',
          child: StatsSummaryLine(fontSize: 16, parts: [
            ('${facts.copies}', true),
            (facts.copies == 1 ? ' comic in ' : ' comics in ', false),
            ('${facts.bySeries.length}', true),
            (' Series', false),
          ])),
      StatsSection(
          title: 'Comics by Series', child: bars(_top(facts.bySeries, 30))),
      StatsSection(
          title: 'Most recent additions',
          child: _ComicList(
              comics: recent.take(5).toList(),
              bottom: (comic) => switch (comic.entry.addedAt) {
                    final added? => AppFormats.current.formatDate(added),
                    null => '',
                  })),
      StatsSection(
          title: 'Value Totals',
          child: Column(children: [
            for (final total in facts.valueTotals)
              StatsSummaryLine(fontSize: 16, parts: [
                ('${total.label}: ', false),
                (formatStatsMoneyTotals(total.byCurrency), true),
                (', based on ', false),
                ('${total.count}', true),
                (total.count == 1 ? ' comic' : ' comics', false),
              ]),
          ])),
      StatsSection(
          title: 'Most valuable comics',
          child: _ComicList(
              comics: valuable.take(5).toList(),
              bottom: (comic) => AppFormats.current
                  .formatPartialDate(comic.comic.releaseDateParts),
              badge: (comic) => AppFormats.current.formatMoney(
                  comic.personal.personal.marketValueCents,
                  comic.personal.personal.currency ??
                      AppFormats.current.currency))),
      StatsSection(
          title: 'Key Comics',
          child: StatsPieChart(
              emptyLabel: 'No comics',
              values: facts.keyComics,
              colorsByLabel: _keySegments,
              valueLabel: count)),
      StatsSection(
          title: 'Comics by Key Category',
          child: StatsStackedBarChart(
              values: facts.byKeyCategory,
              segmentColors: _keySegments,
              emptyLabel: 'No key categories',
              valueLabel: count)),
      StatsSection(
          title: 'Comics by Publisher',
          child: bars(_top(facts.byPublisher, 15))),
      StatsSection(
          title: 'Purchase price by Series',
          child: StatsSeriesChart(
              values: _top(facts.purchaseBySeries, 25),
              accent: accent,
              emptyLabel: 'No purchase prices',
              valueLabel: money,
              axisLabel: money)),
      StatsSection(title: 'Comics by Grade', child: bars(facts.byGrade)),
      StatsSection(
          title: 'Comics by Release Year',
          child: StatsSeriesChart(
              values: facts.byYear,
              accent: accent,
              emptyLabel: 'No comics',
              valueLabel: count,
              chronological: true)),
      StatsSection(
          title: 'Comics by Creators', child: bars(_top(facts.byCreator, 30))),
      StatsSection(
          title: 'Comics by Characters',
          child: bars(_top(facts.byCharacter, 30))),
    ]);
  }
}

Map<String, num> _top(Map<String, num> values, int count) {
  final ranked = values.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return Map.fromEntries(ranked.take(count));
}

/// One value line: its money per currency and how many comics have a value.
class ComicValueTotal {
  const ComicValueTotal(this.label, this.byCurrency, this.count);
  final String label;
  final Map<String?, int> byCurrency;
  final int count;
}

/// The figures of one Comics statistics tab. Every comic counts each copy.
class ComicCollectionFacts {
  const ComicCollectionFacts._({
    required this.copies,
    required this.bySeries,
    required this.byPublisher,
    required this.purchaseBySeries,
    required this.byGrade,
    required this.byYear,
    required this.byCreator,
    required this.byCharacter,
    required this.keyComics,
    required this.byKeyCategory,
    required this.valueTotals,
    required this.currency,
  });

  factory ComicCollectionFacts.of(
      List<(ComicLibraryEntry, ComicCatalogItem)> comics) {
    var copies = 0;
    final bySeries = <String, num>{};
    final byPublisher = <String, num>{};
    final purchaseBySeries = <String, num>{};
    final byGrade = <String, num>{};
    final byYear = <String, num>{};
    final byCreator = <String, num>{};
    final byCharacter = <String, num>{};
    final keyComics = <String, num>{};
    final byKeyCategory = <String, Map<String, num>>{};
    final purchase = <String?, int>{};
    final cover = <String?, int>{};
    final value = <String?, int>{};
    var purchaseCount = 0, coverCount = 0, valueCount = 0;
    String? currency;
    void add(Map<String, num> counts, String? label, num amount) {
      final clean = label?.trim();
      if (clean == null || clean.isEmpty) return;
      counts[clean] = (counts[clean] ?? 0) + amount;
    }

    for (final (entry, comic) in comics) {
      final personal = entry.personal;
      final quantity = personal.quantity;
      final series = comic.seriesTitle ?? comic.title;
      copies += quantity;
      add(bySeries, series, quantity);
      add(byPublisher, comic.publisher, quantity);
      add(
          byGrade,
          personal.grade?.trim().isNotEmpty == true
              ? personal.grade
              : 'No Grade',
          quantity);
      add(
          byYear,
          (comic.releaseDateParts?.year ?? comic.coverDateParts?.year)
              ?.toString(),
          quantity);
      for (final name in {for (final c in comic.creators) c.name?.trim()}) {
        add(byCreator, name, quantity);
      }
      for (final name in {for (final c in comic.characters) c.name?.trim()}) {
        add(byCharacter, name, quantity);
      }
      final details = personal.details;
      final severity = details.keyComic == true
          ? switch (details.keySeverity) {
              'Major' => 'Major Keys',
              'Trivia' => 'Trivia',
              _ => 'Minor Keys',
            }
          : _noKey;
      add(keyComics, severity, quantity);
      final category = details.keyCategory?.trim();
      if (category != null && category.isNotEmpty) {
        final segments = byKeyCategory[category] ??= {};
        segments[severity] = (segments[severity] ?? 0) + quantity;
      }
      if (personal.pricePaidCents case final price?) {
        final total = price * quantity;
        purchaseCount += quantity;
        purchase[personal.currency] =
            (purchase[personal.currency] ?? 0) + total;
        add(purchaseBySeries, series, total);
        currency ??= personal.currency;
      }
      if (comic.coverPriceCents case final price?) {
        coverCount += quantity;
        cover[personal.currency] =
            (cover[personal.currency] ?? 0) + price * quantity;
      }
      if (personal.marketValueCents case final price?) {
        valueCount += quantity;
        value[personal.currency] =
            (value[personal.currency] ?? 0) + price * quantity;
      }
    }
    return ComicCollectionFacts._(
      copies: copies,
      bySeries: bySeries,
      byPublisher: byPublisher,
      purchaseBySeries: purchaseBySeries,
      byGrade: byGrade,
      byYear: byYear,
      byCreator: byCreator,
      byCharacter: byCharacter,
      keyComics: keyComics,
      byKeyCategory: byKeyCategory,
      valueTotals: [
        ComicValueTotal('Purchase Price', purchase, purchaseCount),
        ComicValueTotal('Cover Price', cover, coverCount),
        if (valueCount > 0) ComicValueTotal('My Value', value, valueCount),
      ],
      currency: currency ?? AppFormats.current.currency,
    );
  }

  final int copies;
  final Map<String, num> bySeries;
  final Map<String, num> byPublisher;
  final Map<String, num> purchaseBySeries;
  final Map<String, num> byGrade;
  final Map<String, num> byYear;
  final Map<String, num> byCreator;
  final Map<String, num> byCharacter;
  final Map<String, num> keyComics;
  final Map<String, Map<String, num>> byKeyCategory;
  final List<ComicValueTotal> valueTotals;

  /// Currency of the purchase price chart.
  final String? currency;
}

typedef _ComicRow = ({
  LibraryWorkspaceContext entry,
  ComicLibraryEntry personal,
  ComicCatalogItem comic,
});

/// Reference comic rows: cover, series, number at the top right, a date line
/// and the publisher, with a value badge on the most valuable list.
class _ComicList extends StatelessWidget {
  const _ComicList({required this.comics, required this.bottom, this.badge});
  final List<_ComicRow> comics;
  final String Function(_ComicRow comic) bottom;
  final String Function(_ComicRow comic)? badge;

  @override
  Widget build(BuildContext context) {
    if (comics.isEmpty) return const Text('No comics');
    return Column(children: [
      for (final row in comics)
        StatsItemTile(
          onTap: () => openWorkspaceEntryDetails(context, row.entry),
          image: LibraryCoverImage(
              title: row.comic.title,
              libraryEntryRef: row.entry.libraryEntryRef,
              imageUrl: row.comic.coverImageUrl,
              fallbackAspectRatio: 2 / 3,
              borderRadius: 0),
          title: row.comic.seriesTitle ?? row.comic.title,
          lines: [
            const SizedBox(height: 14),
            Text(bottom(row)),
          ],
          bottom: row.comic.publisher == null
              ? null
              : Text(row.comic.publisher!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_number(row.comic),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (badge?.call(row) case final value?) StatsValueBadge(value),
              ]),
        ),
    ]);
  }
}

String _number(ComicCatalogItem comic) {
  final number = '${comic.issueNumber ?? ''}${comic.variant ?? ''}';
  return number.isEmpty ? '' : '#$number';
}
