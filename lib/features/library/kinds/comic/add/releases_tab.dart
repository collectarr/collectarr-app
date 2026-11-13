import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/capability.dart';
import 'package:collectarr_app/features/library/add/panes/search_pane.dart';
import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:collectarr_app/features/library/entries/record.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/series.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_issue_label.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/app_checkbox.dart';
import 'package:collectarr_app/ui/app_click_target.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Add Comics NCBD tab: the comics Core lists as released in a week, as
/// the reference's New Comic Book Day.
final class ComicReleasesTab extends LibraryAddKindTab {
  const ComicReleasesTab();

  @override
  String get label => 'NCBD';

  @override
  IconData get icon => AppIcons.calendar;

  @override
  double get dialogWidth => 1189;

  @override
  Widget build(BuildContext context, LibraryAddKindTabRequest request) =>
      _ComicReleasesPane(request: request);
}

/// Which of the period's releases the tab lists.
enum ComicReleaseFilter {
  all('All'),
  firstIssues("#1's"),
  mySeries('My Series'),
  pullList('Pull List');

  const ComicReleaseFilter(this.label);
  final String label;
}

/// How the tab orders the period's issues.
enum ComicReleaseSort {
  variantCount('Sort by variant count', AppIcons.sortCount),
  alphabetical('Sort alphabetically', AppIcons.sortAlpha);

  const ComicReleaseSort(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// One choice of the week menu, from [start] to [end] inclusive.
@immutable
class ComicReleasePeriod {
  const ComicReleasePeriod(this.title, this.start, this.end);
  final String title;
  final DateTime start;
  final DateTime end;

  String get range => comicReleaseRangeLabel(start, end);
  bool includes(DateTime day) => !day.isBefore(start) && !day.isAfter(end);
}

/// The Sunday that starts [day]'s release week, which runs to Saturday as
/// in the reference.
DateTime comicReleaseWeekStart(DateTime day) {
  final date = DateTime.utc(day.year, day.month, day.day);
  return date.subtract(Duration(days: date.weekday % 7));
}

/// "Week 43 | Oct 18 - Oct 24": the ISO week of the Monday after [start].
String comicReleaseRangeLabel(DateTime start, DateTime end) {
  final thursday = start.add(const Duration(days: 4));
  final week =
      thursday.difference(DateTime.utc(thursday.year, 1, 1)).inDays ~/ 7 + 1;
  String day(DateTime date) =>
      '${comicMonthNames[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  return 'Week $week | ${day(start)} - ${day(end)}';
}

/// The reference's week menu around [today].
List<ComicReleasePeriod> comicReleasePeriods(DateTime today) {
  final current = comicReleaseWeekStart(today);
  DateTime weeks(int count) => current.add(Duration(days: 7 * count));
  ComicReleasePeriod week(String title, int offset) => ComicReleasePeriod(
      title, weeks(offset), weeks(offset).add(const Duration(days: 6)));
  return [
    week('Earlier', -2),
    week('Last week', -1),
    week('This week', 0),
    week('Next week', 1),
    week('Later', 2),
    ComicReleasePeriod(
        'All weeks', weeks(-2), weeks(8).add(const Duration(days: 6))),
  ];
}

String _isoDate(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

Map<String, Object> _rangeQuery(ComicReleasePeriod period) =>
    {'start': _isoDate(period.start), 'end': _isoDate(period.end)};

/// How many issues and variants each of [periods] holds, by title.
Future<Map<String, int>> loadComicReleaseCounts(
  ApiClient api,
  List<ComicReleasePeriod> periods,
) async {
  final rows = await api.getJsonRows(
    '/api/v1/metadata/comics/releases/counts',
    queryParameters: _rangeQuery(periods.last),
  );
  return {
    for (final period in periods)
      period.title: rows.fold<int>(
        0,
        (total, row) =>
            period.includes(DateTime.parse('${row['date']}T00:00:00Z'))
                ? total + (row['count'] as int)
                : total,
      ),
  };
}

/// One issue of the period with all its variants.
@immutable
class ComicReleaseIssue {
  const ComicReleaseIssue(this.items);
  final List<CatalogSearchCandidate> items;

  ComicCatalogFields get _fields => items.first.comicCatalogFields;
  String get series => _fields.metadata?.seriesTitle?.trim().isNotEmpty == true
      ? _fields.metadata!.seriesTitle!.trim()
      : _fields.title;
  String? get publisher => _fields.metadata?.publisher;
  String get number => _fields.metadata?.issueNumber?.trim() ?? '';
  String? get seriesKey => _comicItemSeriesKey(items.first);
}

String? _comicItemSeriesKey(CatalogSearchCandidate item) {
  final comic = item.comicCatalogFields.metadata;
  return comicSeriesKey({
    'series_title': comic?.seriesTitle,
    'publisher': comic?.publisher,
    'volume_start_year': comic?.volumeStartYear,
  });
}

/// [items] grouped into issues, ordered by series and number.
List<ComicReleaseIssue> comicReleaseIssues(List<CatalogSearchCandidate> items) {
  final groups = <String, List<CatalogSearchCandidate>>{};
  for (final item in items) {
    final comic = item.comicCatalogFields.metadata;
    groups
        .putIfAbsent(
            '${_comicItemSeriesKey(item) ?? item.reference.id}'
            '#${comic?.issueNumber?.trim()}',
            () => [])
        .add(item);
  }
  return groups.values.map(ComicReleaseIssue.new).toList()
    ..sort(_compareAlphabetically);
}

int _compareAlphabetically(ComicReleaseIssue a, ComicReleaseIssue b) {
  int? number(ComicReleaseIssue issue) =>
      int.tryParse(RegExp(r'^\d+').stringMatch(issue.number) ?? '');
  final bySeries = a.series.toLowerCase().compareTo(b.series.toLowerCase());
  if (bySeries != 0) return bySeries;
  return (number(a) ?? 1 << 30).compareTo(number(b) ?? 1 << 30);
}

/// [issues] in [sort] order: most variants first, then alphabetically.
List<ComicReleaseIssue> comicReleaseSorted(
  Iterable<ComicReleaseIssue> issues,
  ComicReleaseSort sort,
) =>
    issues.toList()
      ..sort((a, b) {
        final byCount = sort == ComicReleaseSort.variantCount
            ? b.items.length.compareTo(a.items.length)
            : 0;
        return byCount != 0 ? byCount : _compareAlphabetically(a, b);
      });

/// Whether [issue] is numbered 1, as "1", "01" or "1/2" is not.
bool comicReleaseIsFirstIssue(ComicReleaseIssue issue) =>
    RegExp(r'^0*1$').hasMatch(issue.number);

/// A variant's block: "#1A", its release date and the variant, with the
/// series above when [withSeries] mixes several.
LibraryAddCoverBlock comicReleaseBlock(
  CatalogSearchCandidate item, {
  required bool withSeries,
}) {
  final comic = item.comicCatalogFields.metadata;
  final date = comic?.releaseDateParts;
  final month = date?.month;
  final day = date?.day;
  return LibraryAddCoverBlock(
    badge: '#${comicIssueText(comic?.issueNumber, comic?.variant) ?? ''}',
    month: month == null || day == null
        ? null
        : '${comicMonthNames[month - 1]} ${day.toString().padLeft(2, '0')},',
    year: date?.year,
    caption: comic?.variantDescription?.trim(),
    title: withSeries ? comic?.seriesTitle?.trim() : null,
  );
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

const _scrollGutter = 15.0;
const _cardExtent = 195.6;
const _rowText =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 20 / 14);
const _boldText =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 20 / 14);

Color _panel(BuildContext context) {
  final palette = appPalette(context);
  return palette.isDark ? const Color(0xff383838) : palette.panelRaised;
}

class _ComicReleasesPane extends StatefulWidget {
  const _ComicReleasesPane({required this.request});
  final LibraryAddKindTabRequest request;

  @override
  State<_ComicReleasesPane> createState() => _ComicReleasesPaneState();
}

class _ComicReleasesPaneState extends State<_ComicReleasesPane> {
  final _periods = comicReleasePeriods(DateTime.now());
  int _period = 0;
  ComicReleaseFilter _filter = ComicReleaseFilter.all;
  ComicReleaseSort _sort = ComicReleaseSort.variantCount;
  Set<String> _pullList = const {};
  Map<String, int> _counts = const {};

  /// The issue whose variants are open; with [_allReleases] every variant.
  ComicReleaseIssue? _opened;
  bool _allReleases = false;

  LibraryAddKindTabRequest get _request => widget.request;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
      _loadCounts();
    });
    readComicPullList().then((keys) {
      if (mounted) setState(() => _pullList = keys);
    });
  }

  Future<void> _loadCounts() async {
    final api = _request.api;
    if (api == null) return;
    try {
      final counts = await loadComicReleaseCounts(api, _periods);
      if (mounted) setState(() => _counts = counts);
    } on Exception {
      // The menu works without its counters; the list reports a dead Core.
    }
  }

  void _load() {
    final api = _request.api;
    if (api == null) return;
    _request.list(api.getJsonRows(
      '/api/v1/metadata/comics/releases',
      queryParameters: _rangeQuery(_periods[_period]),
    ));
  }

  void _choosePeriod(int index) {
    setState(() {
      _period = index;
      _opened = null;
      _allReleases = false;
    });
    _load();
  }

  Set<String> get _ownedSeries => {
        for (final entry in _request.entries)
          if (comicOwnedSeriesKey(entry) case final key?) key,
      };

  bool _passes(ComicReleaseIssue issue) => switch (_filter) {
        ComicReleaseFilter.all => true,
        ComicReleaseFilter.firstIssues => comicReleaseIsFirstIssue(issue),
        ComicReleaseFilter.mySeries => _ownedSeries.contains(issue.seriesKey),
        ComicReleaseFilter.pullList => _pullList.contains(issue.seriesKey),
      };

  Future<void> _editPullList() async {
    final chosen = await showComicPullListDialog(
      context,
      entries: _request.entries,
      selected: _pullList,
    );
    if (chosen == null || !mounted) return;
    await writeComicPullList(chosen);
    if (mounted) setState(() => _pullList = chosen);
  }

  void _setSort(ComicReleaseSort sort) => setState(() => _sort = sort);

  void _back() => setState(() {
        _opened = null;
        _allReleases = false;
      });

  @override
  Widget build(BuildContext context) {
    final issues = comicReleaseSorted(
        comicReleaseIssues(_request.items).where(_passes), _sort);
    final period = _periods[_period];
    final opened = _opened;
    if (opened != null || _allReleases) {
      final shown =
          opened?.items ?? [for (final issue in issues) ...issue.items];
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _DetailHeader(
          period: period,
          issue: opened,
          onBack: _back,
          sort: _SortButtons(selected: _sort, onSelected: _setSort),
        ),
        Expanded(
          child: _request.coverGrid(
            shown,
            (item) => comicReleaseBlock(item, withSeries: opened == null),
          ),
        ),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ColoredBox(
        color: libraryAddSearchRowBackground(context),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _WeekRow(
            periods: _periods,
            selected: _period,
            counts: _counts,
            onSelected: _choosePeriod,
          ),
          _FilterRow(
            selected: _filter,
            onSelected: (filter) => setState(() => _filter = filter),
            onEditPullList: _editPullList,
            sort: _SortButtons(selected: _sort, onSelected: _setSort),
          ),
        ]),
      ),
      Expanded(
        child: ColoredBox(
          color: libraryAddSearchBackground(context),
          child: _body(issues),
        ),
      ),
    ]);
  }

  Widget _body(List<ComicReleaseIssue> issues) {
    if (_request.isLoading && issues.isEmpty) {
      return const LibraryAddSearchingPlaceholder();
    }
    if (_request.error case final error?) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(error, style: _rowText)));
    }
    if (issues.isEmpty) {
      return const Center(child: Text('No releases to show.', style: _rowText));
    }
    final count = issues.fold<int>(0, (sum, issue) => sum + issue.items.length);
    return LayoutBuilder(builder: (context, constraints) {
      // Six blocks across the reference's dialog, beside its scroll bar.
      final columns =
          ((constraints.maxWidth - _scrollGutter) / _cardExtent).floor();
      return CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: _AllReleasesRow(
            count: count,
            onTap: () => setState(() => _allReleases = true),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(right: _scrollGutter, bottom: 5),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns < 1 ? 1 : columns,
              mainAxisExtent: 352,
            ),
            itemCount: issues.length,
            itemBuilder: (context, index) => _IssueCard(
              issue: issues[index],
              onTap: () => setState(() => _opened = issues[index]),
            ),
          ),
        ),
      ]);
    });
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.periods,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final List<ComicReleasePeriod> periods;
  final int selected;
  final Map<String, int> counts;
  final ValueChanged<int> onSelected;

  Widget _arrow(IconData icon, String tooltip, Key key, int target) =>
      Visibility(
        visible: target >= 0 && target < periods.length,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: _Press(
          key: key,
          label: tooltip,
          onClick: () => onSelected(target),
          builder: (context, hovered) => Tooltip(
            message: tooltip,
            child: SizedBox(
              width: 33,
              height: 32,
              child: Icon(icon, size: 14),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final period = periods[selected];
    return SizedBox(
      height: 41,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _arrow(AppIcons.chevronLeft, 'Previous week',
            const ValueKey('comic-releases.previous'), selected - 1),
        PopupMenuButton<int>(
          key: const ValueKey('comic-releases.weeks'),
          tooltip: 'Choose week',
          padding: EdgeInsets.zero,
          position: PopupMenuPosition.under,
          constraints: const BoxConstraints.tightFor(width: 260),
          menuPadding: const EdgeInsets.symmetric(vertical: 5),
          color: palette.isDark ? const Color(0xff444444) : palette.panelRaised,
          onSelected: onSelected,
          itemBuilder: (context) => [
            for (final (index, item) in periods.indexed)
              PopupMenuItem<int>(
                value: index,
                height: 50,
                padding: EdgeInsets.zero,
                child: Container(
                  height: 50,
                  color: index == selected
                      ? palette.utilityAction
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.title, style: _rowText),
                          Text(item.range, style: _rowText),
                        ],
                      ),
                    ),
                    if (counts[item.title] case final count?)
                      _CountPill(count: count),
                  ]),
                ),
              ),
          ],
          child: SizedBox(
            width: 260,
            height: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(period.title, style: _boldText),
                Text(period.range, style: _rowText),
              ],
            ),
          ),
        ),
        _arrow(AppIcons.chevronRight, 'Next week',
            const ValueKey('comic-releases.next'), selected + 1),
      ]),
    );
  }
}

/// A click target screen readers and browser gestures can press too.
class _Press extends StatelessWidget {
  const _Press({
    required super.key,
    required this.label,
    required this.onClick,
    required this.builder,
    this.selected,
  });

  final String label;
  final VoidCallback onClick;
  final Widget Function(BuildContext context, bool hovered) builder;
  final bool? selected;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        selected: selected,
        onTap: onClick,
        excludeSemantics: true,
        child: AppClickTarget(onClick: onClick, builder: builder),
      );
}

class _SortButtons extends StatelessWidget {
  const _SortButtons({required this.selected, required this.onSelected});
  final ComicReleaseSort selected;
  final ValueChanged<ComicReleaseSort> onSelected;

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        for (final sort in ComicReleaseSort.values)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _Press(
              key: ValueKey('comic-releases.sort.${sort.name}'),
              label: sort.label,
              selected: sort == selected,
              onClick: () => onSelected(sort),
              builder: (context, hovered) => Tooltip(
                message: sort.label,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: sort == selected
                        ? const Color(0xff737373)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(sort.icon, size: 18),
                ),
              ),
            ),
          ),
      ]);
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xff605c5c),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text('$count', style: _rowText),
      );
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selected,
    required this.onSelected,
    required this.onEditPullList,
    required this.sort,
  });

  final ComicReleaseFilter selected;
  final ValueChanged<ComicReleaseFilter> onSelected;
  final VoidCallback onEditPullList;
  final Widget sort;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    const values = ComicReleaseFilter.values;
    return Container(
      height: 39,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xff787878))),
      ),
      child: Row(children: [
        for (final (index, filter) in values.indexed)
          _Press(
            key: ValueKey('comic-releases.filter.${filter.name}'),
            label: filter.label,
            selected: filter == selected,
            onClick: () => onSelected(filter),
            builder: (context, hovered) => Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: filter == selected
                    ? const Color(0xff666666)
                    : palette.isDark
                        ? const Color(0xff444444)
                        : palette.panelRaised,
                border: Border.all(
                  color: filter == selected
                      ? palette.textPrimary
                      : const Color(0xff444444),
                ),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(index == 0 ? 4 : 0),
                  right: Radius.circular(index == values.length - 1 ? 4 : 0),
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (filter == ComicReleaseFilter.pullList) ...[
                  const Icon(AppIcons.star, size: 14),
                  const SizedBox(width: 3),
                ],
                Text(filter.label, style: _rowText),
              ]),
            ),
          ),
        _Press(
          key: const ValueKey('comic-releases.edit-pull-list'),
          label: 'Edit Pull List',
          onClick: onEditPullList,
          builder: (context, hovered) => const Tooltip(
            message: 'Edit Pull List',
            child: SizedBox(
              width: 32,
              height: 32,
              child: Icon(AppIcons.edit, size: 15),
            ),
          ),
        ),
        const Spacer(),
        sort,
      ]),
    );
  }
}

class _AllReleasesRow extends StatelessWidget {
  const _AllReleasesRow({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Press(
        key: const ValueKey('comic-releases.all'),
        label: 'Check out all releases in one list',
        onClick: onTap,
        builder: (context, hovered) => Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 5, 3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: _panel(context),
          child: Row(children: [
            const Text('Check out all releases in one list', style: _rowText),
            const SizedBox(width: 15),
            _CountPill(count: count),
            const SizedBox(width: 15),
            const Icon(AppIcons.chevronRight, size: 20),
          ]),
        ),
      );
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({required this.issue, required this.onTap});
  final ComicReleaseIssue issue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return _Press(
      key: ValueKey(issue.items.first.reference.id),
      label: '${issue.series} #${issue.number}',
      onClick: onTap,
      builder: (context, hovered) => Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        color: _panel(context),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(issue.publisher ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 17.1429 / 12,
                          color: palette.isDark
                              ? const Color(0xff888888)
                              : palette.textMuted)),
                  Text(issue.series,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 17.1429 / 12)),
                ],
              ),
            ),
          ),
          Expanded(child: _IssueCover(issue: issue, panel: _panel(context))),
        ]),
      ),
    );
  }
}

/// The issue's cover, with a stack of edges behind it when it has variants.
class _IssueCover extends StatefulWidget {
  const _IssueCover({required this.issue, required this.panel});
  final ComicReleaseIssue issue;
  final Color panel;

  @override
  State<_IssueCover> createState() => _IssueCoverState();
}

class _IssueCoverState extends State<_IssueCover> {
  static const _edgeDepth = 10.0;
  double _aspectRatio = 2 / 3;

  void _measured(double ratio) {
    if ((ratio - _aspectRatio).abs() < .01) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _aspectRatio = ratio);
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.issue.items.first;
    final variants = widget.issue.items.length;
    final stacked = variants > 1;
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth - (stacked ? _edgeDepth : 0);
      final height = (width / _aspectRatio).clamp(0.0, constraints.maxHeight);
      return Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: constraints.maxWidth,
          height: height,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(
              left: 0,
              top: 0,
              width: width,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: stacked
                      ? const [
                          BoxShadow(
                              color: Color(0xff383838), offset: Offset(1, 1)),
                          BoxShadow(
                              color: Color(0xff999999), offset: Offset(5, 5)),
                          BoxShadow(
                              color: Color(0xff383838), offset: Offset(6, 6)),
                          BoxShadow(
                              color: Color(0xff999999), offset: Offset(10, 10)),
                        ]
                      : null,
                ),
                child: LibraryCoverImage(
                  title: item.summary.primaryLabel,
                  mediaKind: item.summary.kind,
                  imageUrl: item.summary.imageUrl,
                  borderRadius: 0,
                  fit: BoxFit.fill,
                  onAspectRatio: _measured,
                ),
              ),
            ),
            Positioned(
              top: -5,
              right: 0,
              child: _CardChip(
                label: '#${widget.issue.number}',
                color: widget.panel,
                borderWidth: 2,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                style: _boldText,
              ),
            ),
            if (stacked)
              Positioned(
                right: 15,
                bottom: 4,
                child: _CardChip(
                  label: '$variants variants',
                  color: const Color(0xff28454d),
                  borderWidth: 1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  style: _rowText,
                ),
              ),
          ]),
        ),
      );
    });
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip({
    required this.label,
    required this.color,
    required this.borderWidth,
    required this.padding,
    required this.style,
  });

  final String label;
  final Color color;
  final double borderWidth;
  final EdgeInsets padding;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: borderWidth),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label, style: style.copyWith(color: Colors.white)),
      );
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.period,
    required this.issue,
    required this.onBack,
    required this.sort,
  });

  final Widget sort;

  final ComicReleasePeriod period;

  /// Null on the page of all releases.
  final ComicReleaseIssue? issue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: libraryAddSearchRowBackground(context),
            child: SizedBox(
              height: 45,
              child: Stack(alignment: Alignment.center, children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const ValueKey('comic-releases.back'),
                    onPressed: onBack,
                    icon: const Icon(AppIcons.chevronLeft, size: 14),
                    label: const Text('Back', style: _rowText),
                  ),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(period.title, style: _boldText),
                  Text(period.range, style: _rowText),
                ]),
              ]),
            ),
          ),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: _panel(context),
              border: const Border(top: BorderSide(color: Color(0xff787878))),
            ),
            child: issue == null
                ? Row(children: [
                    const Text('All Releases',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 21.4286 / 15)),
                    const Spacer(),
                    sort,
                  ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (issue!.publisher case final publisher?)
                        Text(publisher,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.2)),
                      Text(issue!.series,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.2)),
                    ],
                  ),
          ),
        ],
      );
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
