import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_page_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'music_stats_capability.dart';
import 'package:collectarr_app/features/library/detail/library_workspace_detail_navigation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/stats/library_stats_charts.dart';

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
      StatsSection(
          title: 'Albums by Format',
          child: StatsPieChart(
              emptyLabel: 'No albums',
              values: MusicStatsCapability.countFormats(entries))),
      StatsSection(
          title: 'Most recent additions',
          child:
              _AlbumList(entries: recent.take(5).toList(), showTracks: true)),
      StatsSection(
          title: 'Played',
          child: StatsPieChart(emptyLabel: 'No albums', values: {
            'Played': played.length,
            'Not Played': entries.length - played.length
          }, colorsByLabel: const {
            'Played': Color(0x99F44336),
            'Not Played': Color(0x992196F3)
          })),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StatsSection(
            title: 'Most played',
            child: _AlbumList(
                entries: mostPlayed.take(5).toList(),
                detail: (e) =>
                    'Played: ${_music(e).listeningSummary!.totalListenCount} x')),
        StatsSection(
            title: 'Most recently played',
            child: _AlbumList(
                entries: recentPlayed.take(5).toList(),
                detail: (e) =>
                    _date(_music(e).listeningSummary?.lastListened))),
      ]),
    ];
    final charts = <Widget>[
      StatsSection(
          title: 'Albums by Artist',
          child: StatsSeriesChart(
              emptyLabel: 'No albums',
              valueLabel: _albums,
              values: MusicStatsCapability.countArtists(entries),
              accent: accent)),
      StatsSection(
          title: 'Albums by Release Year',
          child: StatsSeriesChart(
              emptyLabel: 'No albums',
              valueLabel: _albums,
              values: years,
              accent: accent,
              chronological: true)),
      StatsSection(
          title: 'Albums by Genre',
          child: StatsSeriesChart(
              emptyLabel: 'No albums',
              valueLabel: _albums,
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
                            StatsSummaryLine(fontSize: 18, parts: [
                              ('$albumCopies', true),
                              (' albums and ', false),
                              (
                                '${MusicStatsCapability.countArtists(entries).length}',
                                true
                              ),
                              (' Artists', false),
                            ]),
                            const SizedBox(height: 14),
                            StatsSummaryLine(fontSize: 16, parts: [
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
                              StatsSummaryLine(fontSize: 16, parts: [
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
                            StatsSummaryLine(fontSize: 18, parts: [
                              ('purchase price: ', false),
                              (money(purchaseTotals), true),
                              (' / current value: ', false),
                              (money(valueTotals), true),
                            ]),
                          ])),
                      const SizedBox(height: 20),
                      StatsTwoColumns(sections: sections),
                      ...charts,
                    ]),
              )))),
    );
  }
}

MusicWorkspaceData _music(LibraryWorkspaceContext entry) =>
    entry.kindPresentationData as MusicWorkspaceData;
String _albums(num value) => '$value albums';
String _date(DateTime? value) => value == null
    ? ''
    : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

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
    return Column(children: [
      for (final entry in entries)
        StatsItemTile(
          onTap: () => openWorkspaceEntryDetails(context, entry),
          image: LibraryCoverImage(
              title: entry.title,
              libraryEntryRef: entry.libraryEntryRef,
              imageUrl: _music(entry).music.coverImageUrl,
              fallbackAspectRatio: 1,
              borderRadius: 0),
          title: entry.title,
          lines: [
            if (_music(entry).music.artist case final artist?)
              Text(artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
          bottom: Text(
              '${_music(entry).facts.formatSummary ?? ''} - ${_music(entry).music.releaseDateParts?.year ?? ''}'),
          trailing: showTracks
              ? Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(AppIcons.searchTracks, size: 11),
                    const SizedBox(width: 2),
                    Text('${MusicStatsCapability.totalTracks([entry])}',
                        style: const TextStyle(fontSize: 12)),
                  ]),
                  Text(
                      _trackLength(
                          MusicStatsCapability.totalRuntimeSeconds([entry])),
                      style: const TextStyle(fontSize: 12)),
                ])
              : detail == null
                  ? null
                  : Text(detail!(entry)),
        ),
    ]);
  }
}
