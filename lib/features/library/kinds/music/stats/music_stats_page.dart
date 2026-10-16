import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'dart:math' as math;

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_page_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'music_stats_capability.dart';
import 'package:collectarr_app/features/library/detail/library_workspace_detail_navigation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';

/// Statistics use canonical disc formats and local entry activity. Collection
/// membership scopes every chart, total and ranked list together.
class MusicStatsPage extends ConsumerStatefulWidget {
  const MusicStatsPage({super.key, required this.state});
  final ShelfState state;

  @override
  ConsumerState<MusicStatsPage> createState() => _MusicStatsPageState();
}

class _MusicStatsPageState extends ConsumerState<MusicStatsPage> {
  String? _collectionId;

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(libraryCollectionsProvider('music'));
    final values =
        collections.asData?.value ?? const <LibraryCollectionSummary>[];
    final selected = values.where((c) => c.id == _collectionId).firstOrNull;
    final entries = widget.state.entries
        .where((entry) =>
            entry.kindPresentationData is MusicWorkspaceData &&
            (selected == null ||
                selected.entryIds.contains(entry.libraryEntryRef?.id.value)))
        .toList();
    final accent = LibraryAccentScope.accentOf(context);
    final recent = [...entries]..sort((a, b) =>
        (b.addedAt ?? DateTime(0)).compareTo(a.addedAt ?? DateTime(0)));
    final played = entries
        .where((e) =>
            _music(e).listeningSummary?.totalListenCount != null &&
            _music(e).listeningSummary!.totalListenCount > 0)
        .toList();
    final mostPlayed = [...played]..sort((a, b) => _music(b)
        .listeningSummary!
        .totalListenCount
        .compareTo(_music(a).listeningSummary!.totalListenCount));
    final recentPlayed = [...played]
      ..sort((a, b) => (_music(b).listeningSummary!.lastListened ?? DateTime(0))
          .compareTo(_music(a).listeningSummary!.lastListened ?? DateTime(0)));
    final years = <String, int>{};
    for (final entry in entries) {
      final year = _music(entry).music.releaseDateParts?.year;
      final label = year?.toString() ?? 'Unknown';
      years[label] = (years[label] ?? 0) + 1;
    }
    var albumCopies = 0;
    final purchaseTotals = <String, int>{};
    final valueTotals = <String, int>{};
    for (final entry in entries) {
      final currency = entry.currency ?? 'Unspecified currency';
      final quantity =
          MusicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch)
                  ?.personal
                  .quantity ??
              1;
      albumCopies += quantity;
      if (entry.pricePaidCents case final price?) {
        purchaseTotals[currency] =
            (purchaseTotals[currency] ?? 0) + price * quantity;
      }
      if (entry.marketValueCents case final value?) {
        valueTotals[currency] = (valueTotals[currency] ?? 0) + value * quantity;
      }
    }
    // Always shown, as in the reference: no prices read as zero.
    String money(Map<String, int> totals) => totals.isEmpty
        ? AppFormats.current.formatMoney(0, AppFormats.current.currency)
        : (totals.keys.toList()..sort())
            .map((currency) => AppFormats.current.formatMoney(totals[currency],
                currency == 'Unspecified currency' ? null : currency))
            .join(' + ');
    final signed = MusicStatsCapability.totalSignedCopies(entries);
    final sections = <Widget>[
      _StatsSection(
          title: 'Albums by Format',
          child: _Distribution(
              values: MusicStatsCapability.countFormats(entries))),
      _StatsSection(
          title: 'Most recent additions',
          child:
              _AlbumList(entries: recent.take(5).toList(), showTracks: true)),
      _StatsSection(
          title: 'Played',
          child: _Distribution(values: {
            'Played': played.length,
            'Not Played': entries.length - played.length
          }, colorsByLabel: const {
            'Played': Color(0x99F44336),
            'Not Played': Color(0x992196F3)
          })),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _StatsSection(
            title: 'Most played',
            child: _AlbumList(
                entries: mostPlayed.take(5).toList(),
                detail: (e) =>
                    'Played: ${_music(e).listeningSummary!.totalListenCount} x')),
        _StatsSection(
            title: 'Most recently played',
            child: _AlbumList(
                entries: recentPlayed.take(5).toList(),
                detail: (e) =>
                    _date(_music(e).listeningSummary?.lastListened))),
      ]),
    ];
    final charts = <Widget>[
      _StatsSection(
          title: 'Albums by Artist',
          child: _SeriesChart(
              values: MusicStatsCapability.countArtists(entries),
              accent: accent)),
      _StatsSection(
          title: 'Albums by Release Year',
          child:
              _SeriesChart(values: years, accent: accent, chronological: true)),
      _StatsSection(
          title: 'Albums by Genre',
          child: _SeriesChart(
              values: MusicStatsCapability.countGenres(entries),
              accent: accent)),
    ];
    return Scaffold(
      backgroundColor: appManagementCanvasColor(context),
      appBar: AppPageHeader(
          icon: Icons.bar_chart,
          title: const Text('Statistics'),
          leading: AppPageBackButton(
              key: const Key('stats.back'),
              onPressed: () => Navigator.of(context).pop())),
      // A 958 px page, as in the reference.
      body: AppManagementContent(
          maxWidth: 998,
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (collections.hasError)
                        const Text('Could not load collections.')
                      else
                        AppPageTabs(
                          tabs: [
                            const AppPageTab(label: 'All Collections'),
                            for (final collection in values)
                              AppPageTab(label: collection.name),
                          ],
                          selectedIndex: selected == null
                              ? 0
                              : values.indexOf(selected) + 1,
                          onSelected: (index) => setState(() => _collectionId =
                              index == 0 ? null : values[index - 1].id),
                        ),
                      // Numbers bold, words regular, as in the reference.
                      Container(
                          color: appManagementPanelColor(context),
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            _SummaryLine(fontSize: 18, parts: [
                              ('$albumCopies', true),
                              (' albums and ', false),
                              (
                                '${MusicStatsCapability.countArtists(entries).length}',
                                true
                              ),
                              (' Artists', false),
                            ]),
                            const SizedBox(height: 14),
                            _SummaryLine(fontSize: 16, parts: [
                              (
                                '${MusicStatsCapability.totalMedia(entries)}',
                                true
                              ),
                              (' discs, ', false),
                              (
                                '${MusicStatsCapability.totalTracks(entries)}',
                                true
                              ),
                              (' tracks / total runtime: ', false),
                              ..._runtimeParts(
                                  MusicStatsCapability.totalRuntimeSeconds(
                                      entries)),
                            ]),
                            if (signed > 0) ...[
                              const SizedBox(height: 14),
                              _SummaryLine(fontSize: 16, parts: [
                                ('$signed', true),
                                (
                                  signed == 1
                                      ? ' signed album'
                                      : ' signed albums',
                                  false
                                ),
                              ]),
                            ],
                            const SizedBox(height: 14),
                            _SummaryLine(fontSize: 18, parts: [
                              ('purchase price: ', false),
                              (money(purchaseTotals), true),
                              (' / current value: ', false),
                              (money(valueTotals), true),
                            ]),
                          ])),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                          builder: (context, constraints) => constraints
                                      .maxWidth >=
                                  800
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      for (var column = 0;
                                          column < 2;
                                          column++) ...[
                                        if (column == 1)
                                          const SizedBox(width: 32),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                              for (var i = column;
                                                  i < sections.length;
                                                  i += 2)
                                                sections[i]
                                            ])),
                                      ],
                                    ])
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: sections)),
                      ...charts,
                    ]),
              )))),
    );
  }
}

MusicWorkspaceData _music(LibraryWorkspaceContext entry) =>
    entry.kindPresentationData as MusicWorkspaceData;
String _date(DateTime? value) => value == null
    ? ''
    : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Container(
          color: appManagementPanelColor(context),
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            child,
          ])));
}

/// A summary line with bold figures between regular words.
class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.parts, required this.fontSize});
  final List<(String, bool)> parts;
  final double fontSize;
  @override
  Widget build(BuildContext context) => Text.rich(
      TextSpan(children: [
        for (final (text, bold) in parts)
          TextSpan(
              text: text,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      ]),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: fontSize));
}

/// "2 days, 5 hours, 32 minutes" with the figures bold.
List<(String, bool)> _runtimeParts(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final units = [
    (minutes ~/ (24 * 60), 'day'),
    (minutes ~/ 60 % 24, 'hour'),
    (minutes % 60, 'minute'),
  ].where((unit) => unit.$1 > 0).toList();
  if (units.isEmpty) return const [('0', true), (' minutes', false)];
  return [
    for (var i = 0; i < units.length; i++) ...[
      if (i > 0) (', ', false),
      ('${units[i].$1}', true),
      (' ${units[i].$2}${units[i].$1 == 1 ? '' : 's'}', false),
    ],
  ];
}

String _trackLength(int seconds) {
  String two(int value) => value.toString().padLeft(2, '0');
  final minutes = seconds ~/ 60 % 60;
  return seconds >= 3600
      ? '${seconds ~/ 3600}:${two(minutes)}:${two(seconds % 60)}'
      : '$minutes:${two(seconds % 60)}';
}

/// Reference album rows: a 90 px cover, blue title, bold artist,
/// format and year at the bottom, and optionally tracks and length.
class _AlbumList extends StatelessWidget {
  const _AlbumList(
      {required this.entries, this.detail, this.showTracks = false});
  final List<LibraryWorkspaceContext> entries;
  final String Function(LibraryWorkspaceContext)? detail;
  final bool showTracks;
  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Text('No albums');
    final palette = appPalette(context);
    return Column(children: [
      for (final entry in entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: appManagementPanelColor(context),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 3,
                    offset: Offset(0, 1)),
              ],
            ),
            child: InkWell(
              onTap: () => openWorkspaceEntryDetails(context, entry),
              child: SizedBox(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                            width: 90,
                            child: LibraryCoverImage(
                                title: entry.title,
                                libraryEntryRef: entry.libraryEntryRef,
                                imageUrl: _music(entry).music.coverImageUrl,
                                fallbackAspectRatio: 1,
                                borderRadius: 0)),
                        const SizedBox(width: 7),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(entry.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: palette.utilityAction)),
                              if (_music(entry).music.artist case final artist?)
                                Text(artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text(
                                  '${_music(entry).facts.formatSummary ?? ''} - ${_music(entry).music.releaseDateParts?.year ?? ''}'),
                            ])),
                        const SizedBox(width: 8),
                        if (showTracks)
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  const Icon(AppIcons.searchTracks, size: 11),
                                  const SizedBox(width: 2),
                                  Text(
                                      '${MusicStatsCapability.totalTracks([
                                            entry
                                          ])}',
                                      style: const TextStyle(fontSize: 12)),
                                ]),
                                Text(
                                    _trackLength(MusicStatsCapability
                                        .totalRuntimeSeconds([entry])),
                                    style: const TextStyle(fontSize: 12)),
                              ])
                        else if (detail != null)
                          Text(detail!(entry)),
                      ]),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

class _Distribution extends StatelessWidget {
  const _Distribution({required this.values, this.colorsByLabel = const {}});
  final Map<String, int> values;
  final Map<String, Color> colorsByLabel;
  @override
  Widget build(BuildContext context) {
    final ranked = values.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = ranked.fold(0, (n, e) => n + e.value);
    if (total == 0) return const Text('No albums');
    const chartPalette = [
      Color(0xFFD43D51),
      Color(0xFFE1604E),
      Color(0xFFEA8150),
      Color(0xFFF0A059),
      Color(0xFFF3BE6A),
      Color(0xFFD7BC50),
      Color(0xFFB4BC3C),
      Color(0xFF88BC32),
      Color(0xFF4BBA38),
    ];
    final colors = [
      for (var i = 0; i < ranked.length; i++)
        colorsByLabel[ranked[i].key] ?? chartPalette[i % chartPalette.length]
    ];
    return Column(children: [
      Wrap(spacing: 16, runSpacing: 6, children: [
        for (var i = 0; i < ranked.length; i++)
          Row(mainAxisSize: MainAxisSize.min, children: [
            // Reference legend: a 40 x 12 swatch and the label; counts
            // are in the chart tooltip.
            Container(width: 40, height: 12, color: colors[i]),
            const SizedBox(width: 6),
            Text(ranked[i].key, style: const TextStyle(fontSize: 12)),
          ]),
      ]),
      const SizedBox(height: 12),
      LayoutBuilder(
          builder: (context, constraints) => SizedBox(
                height: math.min(420, constraints.maxWidth),
                width: math.min(420, constraints.maxWidth),
                child: Tooltip(
                    message: [
                      for (final e in ranked)
                        '${e.key}: ${e.value} (${(e.value / total * 100).toStringAsFixed(1)}%)'
                    ].join('\n'),
                    child: CustomPaint(
                        painter: _PiePainter(
                            [for (final e in ranked) e.value], colors))),
              )),
    ]);
  }
}

class _PiePainter extends CustomPainter {
  const _PiePainter(this.values, this.colors);
  final List<int> values;
  final List<Color> colors;
  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0, (a, b) => a + b);
    final side = math.min(size.width, size.height);
    final rect = Rect.fromCenter(
        center: size.center(Offset.zero), width: side, height: side);
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = colors[i]);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter oldDelegate) =>
      !listEquals(values, oldDelegate.values) ||
      !listEquals(colors, oldDelegate.colors);
}

class _SeriesChart extends StatelessWidget {
  const _SeriesChart(
      {required this.values, required this.accent, this.chronological = false});
  final Map<String, int> values;
  final Color accent;
  final bool chronological;
  @override
  Widget build(BuildContext context) {
    var entries = values.entries.toList();
    if (chronological) {
      final years = entries
          .map((e) => int.tryParse(e.key))
          .whereType<int>()
          .toList()
        ..sort();
      if (years.isNotEmpty) {
        entries = [
          for (var year = years.first; year <= years.last; year++)
            MapEntry('$year', values['$year'] ?? 0),
          if (values['Unknown'] case final count?) MapEntry('Unknown', count)
        ];
      }
    } else {
      entries.sort((a, b) => b.value.compareTo(a.value));
    }
    if (entries.isEmpty) return const Text('No albums');
    final maximum = entries.map((e) => e.value).reduce(math.max);
    return SizedBox(
        height: 350,
        child: LayoutBuilder(builder: (context, constraints) {
          final width = math.max(constraints.maxWidth, entries.length * 54.0);
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                  width: width,
                  child: _SeriesPlot(
                      entries: entries,
                      accent: accent,
                      maximum: maximum,
                      area: chronological)));
        }));
  }
}

class _SeriesPlot extends StatelessWidget {
  const _SeriesPlot(
      {required this.entries,
      required this.accent,
      required this.maximum,
      required this.area});
  final List<MapEntry<String, int>> entries;
  final Color accent;
  final int maximum;
  final bool area;
  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
            child: Stack(children: [
          Positioned.fill(
              child: CustomPaint(
                  painter: _SeriesPainter(
                      entries: entries,
                      accent: accent,
                      maximum: maximum,
                      area: area,
                      gridColor: appPalette(context).divider))),
          Positioned.fill(
              child: Row(children: [
            for (final entry in entries)
              Expanded(
                  child: Tooltip(
                      message: '${entry.key}: ${entry.value} albums',
                      child: const SizedBox.expand()))
          ])),
        ])),
        SizedBox(
            height: 50,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final entry in entries)
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(entry.key,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11))))
            ])),
      ]);
}

class _SeriesPainter extends CustomPainter {
  const _SeriesPainter(
      {required this.entries,
      required this.accent,
      required this.maximum,
      required this.area,
      required this.gridColor});
  final List<MapEntry<String, int>> entries;
  final Color accent;
  final int maximum;
  final bool area;
  final Color gridColor;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 5; i++) {
      canvas.drawLine(Offset(0, size.height * i / 5),
          Offset(size.width, size.height * i / 5), grid);
    }
    final step = size.width / entries.length;
    final points = [
      for (var i = 0; i < entries.length; i++)
        Offset((i + .5) * step,
            size.height * (1 - entries[i].value / math.max(1, maximum)))
    ];
    if (area) {
      final path = Path()..moveTo(points.first.dx, size.height);
      for (final point in points) {
        path.lineTo(point.dx, point.dy);
      }
      path
        ..lineTo(points.last.dx, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = accent.withValues(alpha: .45));
      final line = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        line.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
          line,
          Paint()
            ..color = accent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      for (final point in points) {
        canvas.drawCircle(point, 3, Paint()..color = accent);
      }
    } else {
      for (var i = 0; i < points.length; i++) {
        canvas.drawRect(
            Rect.fromLTRB(i * step + step * .1, points[i].dy,
                (i + 1) * step - step * .1, size.height),
            Paint()..color = accent.withValues(alpha: .65));
      }
    }
  }

  @override
  bool shouldRepaint(_SeriesPainter old) =>
      !listEquals(entries, old.entries) ||
      accent != old.accent ||
      maximum != old.maximum ||
      area != old.area ||
      gridColor != old.gridColor;
}
