import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/capability.dart';
import 'package:collectarr_app/features/library/entries/record.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/series.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/app_checkbox.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Add Comics NCBD tab: the comics Core lists as released in one week,
/// as the reference's New Comic Book Day.
final class ComicReleasesTab extends LibraryAddKindTab {
  const ComicReleasesTab();

  @override
  String get label => 'NCBD';

  @override
  IconData get icon => AppIcons.calendar;

  @override
  LibraryAddCoverBlock coverBlock(CatalogSearchCandidate item) =>
      comicAddCoverBlock(item);

  @override
  Widget buildControls(
          BuildContext context, LibraryAddKindTabRequest request) =>
      _ComicReleaseControls(request: request);
}

/// Which releases of the week the tab lists.
enum ComicReleaseFilter {
  all('All'),
  firstIssues("#1's"),
  mySeries('My Series'),
  pullList('Pull List');

  const ComicReleaseFilter(this.label);
  final String label;
}

/// The Sunday that starts [day]'s release week, which runs to Saturday as
/// in the reference.
DateTime comicReleaseWeekStart(DateTime day) {
  final date = DateTime.utc(day.year, day.month, day.day);
  return date.subtract(Duration(days: date.weekday % 7));
}

/// "Week 43 | Oct 18 - Oct 24": the ISO week of the Monday after [start].
String comicReleaseWeekLabel(DateTime start) {
  final end = start.add(const Duration(days: 6));
  final monday = start.add(const Duration(days: 1));
  final thursday = monday.add(const Duration(days: 3));
  final firstThursday = DateTime.utc(thursday.year, 1, 1);
  final week = thursday.difference(firstThursday).inDays ~/ 7 + 1;
  String day(DateTime date) =>
      '${comicMonthNames[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  return 'Week $week | ${day(start)} - ${day(end)}';
}

String _isoDate(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// The week's releases from Core, narrowed to the series in [seriesKeys]
/// when that is set.
Future<List<Map<String, dynamic>>> loadComicReleaseRows(
  ApiClient api, {
  required DateTime weekStart,
  required bool firstIssues,
  Set<String>? seriesKeys,
}) async {
  final rows = await api.getJsonRows(
    '/api/v1/metadata/comics/releases',
    queryParameters: {
      'start': _isoDate(weekStart),
      'end': _isoDate(weekStart.add(const Duration(days: 6))),
      if (firstIssues) 'first_issues': true,
    },
  );
  if (seriesKeys == null) return rows;
  return [
    for (final row in rows)
      if (comicSeriesKey(
              (row['kind_data'] as Map?)?.cast<String, dynamic>() ?? const {})
          case final key? when seriesKeys.contains(key))
        row,
  ];
}

const _pullListKey = 'collectarr.comic.pull_list';

/// The series the user follows for new releases, as [comicSeriesKey] names
/// them; kept on this device.
Future<Set<String>> readComicPullList() async =>
    ((await SharedPreferences.getInstance()).getStringList(_pullListKey) ??
            const [])
        .toSet();

Future<void> writeComicPullList(Set<String> keys) async =>
    (await SharedPreferences.getInstance())
        .setStringList(_pullListKey, keys.toList()..sort());

class _ComicReleaseControls extends StatefulWidget {
  const _ComicReleaseControls({required this.request});
  final LibraryAddKindTabRequest request;

  @override
  State<_ComicReleaseControls> createState() => _ComicReleaseControlsState();
}

class _ComicReleaseControlsState extends State<_ComicReleaseControls> {
  late DateTime _week = comicReleaseWeekStart(DateTime.now());
  ComicReleaseFilter _filter = ComicReleaseFilter.all;
  Set<String> _pullList = const {};

  @override
  void initState() {
    super.initState();
    readComicPullList().then((keys) {
      if (!mounted) return;
      _pullList = keys;
      _load();
    });
  }

  Set<String> get _ownedSeries => {
        for (final entry in widget.request.entries)
          if (comicOwnedSeriesKey(entry) case final key?) key,
      };

  void _load() {
    final api = widget.request.api;
    if (api == null) return;
    widget.request.list(loadComicReleaseRows(
      api,
      weekStart: _week,
      firstIssues: _filter == ComicReleaseFilter.firstIssues,
      seriesKeys: switch (_filter) {
        ComicReleaseFilter.mySeries => _ownedSeries,
        ComicReleaseFilter.pullList => _pullList,
        _ => null,
      },
    ));
  }

  void _shiftWeek(int weeks) {
    setState(() => _week = _week.add(Duration(days: 7 * weeks)));
    _load();
  }

  void _setFilter(ComicReleaseFilter filter) {
    setState(() => _filter = filter);
    _load();
  }

  Future<void> _editPullList() async {
    final chosen = await showComicPullListDialog(
      context,
      entries: widget.request.entries,
      selected: _pullList,
    );
    if (chosen == null || !mounted) return;
    await writeComicPullList(chosen);
    setState(() => _pullList = chosen);
    if (_filter == ComicReleaseFilter.pullList) _load();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final busy = widget.request.isLoading;
    return Row(children: [
      for (final filter in ComicReleaseFilter.values)
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: TextButton(
            key: ValueKey('comic-releases.filter.${filter.name}'),
            onPressed: busy ? null : () => _setFilter(filter),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: palette.textPrimary,
              backgroundColor: filter == _filter
                  ? palette.textPrimary.withValues(alpha: .18)
                  : Colors.transparent,
              shape: const RoundedRectangleBorder(),
              textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w400, height: 20 / 14),
            ),
            child: Text(filter.label),
          ),
        ),
      IconButton(
        tooltip: 'Edit Pull List',
        onPressed: _editPullList,
        icon: const Icon(AppIcons.edit, size: 15),
      ),
      const Spacer(),
      IconButton(
        key: const ValueKey('comic-releases.previous'),
        tooltip: 'Earlier',
        onPressed: busy ? null : () => _shiftWeek(-1),
        icon: const Icon(Icons.chevron_left),
      ),
      Text(comicReleaseWeekLabel(_week),
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, height: 20 / 14)),
      IconButton(
        key: const ValueKey('comic-releases.next'),
        tooltip: 'Later',
        onPressed: busy ? null : () => _shiftWeek(1),
        icon: const Icon(Icons.chevron_right),
      ),
    ]);
  }
}

/// Picks the followed series from the library's series.
Future<Set<String>?> showComicPullListDialog(
  BuildContext context, {
  required Iterable<LibraryEntryRecord> entries,
  required Set<String> selected,
}) {
  final series = <String, String>{};
  for (final entry in entries) {
    final key = comicOwnedSeriesKey(entry);
    if (key == null) continue;
    final data = entry.catalogData;
    final title = (data['series_title'] as String).trim();
    final volume = data['volume_start_year'];
    final publisher = (data['publisher'] as String?)?.trim();
    series[key] = [
      volume == null ? title : '$title ($volume)',
      if (publisher != null && publisher.isNotEmpty) publisher,
    ].join(' · ');
  }
  final ordered = series.entries.toList()
    ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
  return showAppDialog<Set<String>>(
    context: context,
    builder: (context) => _ComicPullListDialog(
      series: ordered,
      selected: selected,
    ),
  );
}

class _ComicPullListDialog extends StatefulWidget {
  const _ComicPullListDialog({required this.series, required this.selected});
  final List<MapEntry<String, String>> series;
  final Set<String> selected;

  @override
  State<_ComicPullListDialog> createState() => _ComicPullListDialogState();
}

class _ComicPullListDialogState extends State<_ComicPullListDialog> {
  late final Set<String> _chosen = {...widget.selected};

  @override
  Widget build(BuildContext context) => AccentAlertDialog(
        headerIcon: AppIcons.calendar,
        title: const Text('Pull List'),
        content: SizedBox(
          width: 420,
          height: 420,
          child: widget.series.isEmpty
              ? const Center(
                  child: Text('Add comics to follow their series here.'))
              : ListView(children: [
                  for (final MapEntry(:key, :value) in widget.series)
                    AppCheckboxTile(
                      value: _chosen.contains(key),
                      label: value,
                      onChanged: (checked) => setState(() =>
                          checked ? _chosen.add(key) : _chosen.remove(key)),
                    ),
                ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_chosen),
            child: const Text('Save'),
          ),
        ],
      );
}
