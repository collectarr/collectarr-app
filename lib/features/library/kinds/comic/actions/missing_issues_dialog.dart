import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_click_target.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/kinds/comic/actions/missing_issues_report.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

Future<void> showComicMissingComicsDialog({
  required BuildContext context,
  required LibraryKindRegistration type,
  required LibraryProjection projection,
  required Color accent,
}) async {
  await showAppDialog<void>(
    context: context,
    builder: (dialogContext) => _MissingComicsDialog(
      projection: projection,
      accent: accent,
    ),
  );
}

/// The reference's window inset around Missing Comics.
const _windowInset = 30.0;
const _seriesWidth = 460.0;
const _countWidth = 68.0;
const _rowHeight = 30.0;

// The reference's table: #262626 body ruled #383838 under a #464950 heading,
// below a #131313 filter bar.
Color _bodyColor(AppThemePalette palette) =>
    palette.isDark ? const Color(0xff262626) : palette.surface;
Color _ruleColor(AppThemePalette palette) =>
    palette.isDark ? const Color(0xff383838) : palette.divider;
Color _headingColor(AppThemePalette palette) =>
    palette.isDark ? const Color(0xff464950) : palette.panelRaised;
Color _barColor(AppThemePalette palette) =>
    palette.isDark ? const Color(0xff131313) : palette.panel;

class _MissingComicsDialog extends StatefulWidget {
  const _MissingComicsDialog({
    required this.projection,
    required this.accent,
  });

  final LibraryProjection projection;
  final Color accent;

  @override
  State<_MissingComicsDialog> createState() => _MissingComicsDialogState();
}

class _MissingComicsDialogState extends State<_MissingComicsDialog> {
  final _filter = TextEditingController();
  final _hidden = <String>{};
  var _showVariants = false;
  var _showOnOrder = false;
  var _showUnreleased = true;
  var _compact = true;
  var _ascending = true;
  var _seriesAscending = true;

  MissingComicReportOptions get _options => MissingComicReportOptions(
        includeVariants: _showVariants,
        excludeOnOrder: !_showOnOrder,
        excludeUnreleased: !_showUnreleased,
        ascending: _ascending,
        verbose: !_compact,
      );

  List<MissingComicSeriesReport> get _reports {
    final filter = _filter.text.trim().toLowerCase();
    final reports = buildMissingComicSeriesReports(
      widget.projection.allItems,
      options: _options,
    )
        .where((report) =>
            !_hidden.contains(report.seriesKey) &&
            report.seriesTitle.toLowerCase().contains(filter))
        .toList();
    return _seriesAscending ? reports : reports.reversed.toList();
  }

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  Future<void> _downloadPdf(List<MissingComicSeriesReport> reports) async {
    final doc = await buildMissingComicsPdfDocument(
        reports: reports, options: _options);
    await Printing.sharePdf(
        bytes: await doc.save(), filename: 'missing-comics.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final reports = _reports;
    final window = MediaQuery.sizeOf(context);
    return LibraryDialogScaffold(
      accent: widget.accent,
      width: window.width - 2 * _windowInset,
      height: window.height - 2 * _windowInset,
      insetPadding: const EdgeInsets.all(_windowInset),
      header: AccentDialogHeader(
        title: 'Missing Comics',
        icon: AppIcons.missing,
        onClose: () => Navigator.of(context).pop(),
      ),
      contextBar: _FilterBar(
        filter: _filter,
        onFilterChanged: () => setState(() {}),
        options: [
          _Option('Show variants', _showVariants,
              (value) => setState(() => _showVariants = value)),
          _Option('Show "On Order"', _showOnOrder,
              (value) => setState(() => _showOnOrder = value)),
          _Option('Show unreleased', _showUnreleased,
              (value) => setState(() => _showUnreleased = value)),
          _Option('Compact list', _compact,
              (value) => setState(() => _compact = value)),
        ],
        ascending: _ascending,
        onAscendingChanged: (value) => setState(() => _ascending = value),
      ),
      body: ColoredBox(
        color: _bodyColor(palette),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeadingRow(
              seriesAscending: _seriesAscending,
              onSortSeries: () =>
                  setState(() => _seriesAscending = !_seriesAscending),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) => _SeriesRow(
                  report: reports[index],
                  issues: missingComicIssuesText(reports[index], _options),
                  onHide: () =>
                      setState(() => _hidden.add(reports[index].seriesKey)),
                ),
              ),
            ),
          ],
        ),
      ),
      footer: DialogActionFooter(actions: [
        DialogActionButton(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
        DialogActionButton(
          key: const ValueKey('missing-comics-download-pdf'),
          label: 'Download PDF',
          icon: AppIcons.print,
          primary: true,
          width: 142,
          onPressed: reports.isEmpty ? null : () => _downloadPdf(reports),
        ),
      ]),
    );
  }
}

class _Option {
  const _Option(this.label, this.value, this.onChanged);

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.onFilterChanged,
    required this.options,
    required this.ascending,
    required this.onAscendingChanged,
  });

  final TextEditingController filter;
  final VoidCallback onFilterChanged;
  final List<_Option> options;
  final bool ascending;
  final ValueChanged<bool> onAscendingChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      height: 40,
      color: _barColor(palette),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 205,
              height: 28,
              child: TextField(
                key: const ValueKey('missing-comics-filter'),
                controller: filter,
                onChanged: (_) => onFilterChanged(),
                style: TextStyle(fontSize: 14, color: palette.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Filter Series...',
                  isDense: true,
                  filled: true,
                  fillColor: palette.isDark
                      ? const Color(0xff444444)
                      : palette.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            for (final option in options) ...[
              _OptionCheck(option: option),
              const SizedBox(width: 15),
            ],
            Text('Sort issues',
                style: TextStyle(fontSize: 14, color: palette.textPrimary)),
            const SizedBox(width: 4),
            _SortSwitch(ascending: ascending, onChanged: onAscendingChanged),
          ],
        ),
      ),
    );
  }
}

class _OptionCheck extends StatelessWidget {
  const _OptionCheck({required this.option});

  final _Option option;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Semantics(
      label: option.label,
      checked: option.value,
      excludeSemantics: true,
      child: AppClickTarget(
        onClick: () => option.onChanged(!option.value),
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: option.value ? palette.utilityAction : Colors.white,
                border: Border.all(
                    color: option.value
                        ? palette.utilityAction
                        : const Color(0xff767676)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: option.value
                  ? const Icon(AppIcons.check, size: 9, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 5),
            Text(option.label,
                style: TextStyle(fontSize: 14, color: palette.textPrimary)),
          ],
        ),
      ),
    );
  }
}

/// The reference's Asc/Desc pill: blue with its knob at the left for Asc.
class _SortSwitch extends StatelessWidget {
  const _SortSwitch({required this.ascending, required this.onChanged});

  final bool ascending;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final knob = Container(
      width: 16,
      height: 16,
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
    final label = Text(ascending ? 'Asc' : 'Desc',
        style: const TextStyle(color: Colors.white, fontSize: 13));
    return Semantics(
      label: 'Sort issues',
      value: ascending ? 'Ascending' : 'Descending',
      button: true,
      excludeSemantics: true,
      child: AppClickTarget(
        key: const ValueKey('missing-comics-sort'),
        onClick: () => onChanged(!ascending),
        builder: (context, _) => Container(
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: ascending
                ? palette.utilityAction
                : (palette.isDark ? const Color(0xff555555) : palette.divider),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ascending
                ? [
                    knob,
                    const SizedBox(width: 6),
                    label,
                    const SizedBox(width: 6)
                  ]
                : [
                    const SizedBox(width: 6),
                    label,
                    const SizedBox(width: 6),
                    knob
                  ],
          ),
        ),
      ),
    );
  }
}

class _HeadingRow extends StatelessWidget {
  const _HeadingRow(
      {required this.seriesAscending, required this.onSortSeries});

  final bool seriesAscending;
  final VoidCallback onSortSeries;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    return Container(
      height: _rowHeight,
      color: _headingColor(palette),
      child: DefaultTextStyle.merge(
        style: style.copyWith(color: palette.textPrimary),
        child: Row(
          children: [
            AppClickTarget(
              onClick: onSortSeries,
              builder: (context, _) => _Cell(
                width: _seriesWidth,
                child: Row(children: [
                  const Text('Series'),
                  const SizedBox(width: 3),
                  Icon(
                      seriesAscending
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 18,
                      color: palette.textPrimary),
                ]),
              ),
            ),
            const _Cell(
                width: _countWidth,
                alignment: Alignment.centerRight,
                child: Text('Owned')),
            const _Cell(
                width: _countWidth,
                alignment: Alignment.centerRight,
                child: Text('Missing')),
            const Expanded(child: _Cell(child: Text('Missing Issues'))),
          ],
        ),
      ),
    );
  }
}

class _SeriesRow extends StatelessWidget {
  const _SeriesRow({
    required this.report,
    required this.issues,
    required this.onHide,
  });

  final MissingComicSeriesReport report;
  final String issues;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      constraints: const BoxConstraints(minHeight: _rowHeight),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _ruleColor(palette))),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 14, color: palette.textPrimary),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Cell(width: _seriesWidth, child: Text(report.seriesTitle)),
              _Cell(
                  width: _countWidth,
                  alignment: Alignment.centerRight,
                  child: Text('${report.entryIssueCount}')),
              _Cell(
                  width: _countWidth,
                  alignment: Alignment.centerRight,
                  child: Text('${report.missingIssueCount}')),
              Expanded(child: _Cell(child: Text(issues))),
              _Cell(
                width: 42,
                ruled: false,
                child: AppClickTarget(
                  key: ValueKey('missing-comics-hide-${report.seriesKey}'),
                  onClick: onHide,
                  builder: (context, _) => Text('Hide',
                      style: TextStyle(color: palette.utilityAction)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A table cell with the reference's 5 px padding and right rule.
class _Cell extends StatelessWidget {
  const _Cell({
    required this.child,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.ruled = true,
  });

  final Widget child;
  final double? width;
  final Alignment alignment;
  final bool ruled;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        padding: const EdgeInsets.all(5),
        alignment: alignment,
        decoration: ruled
            ? BoxDecoration(
                border: Border(
                    right: BorderSide(color: _ruleColor(appPalette(context)))))
            : null,
        child: child,
      );
}
