import 'package:collectarr_app/features/library/add/library_add_launcher.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/missing_comics_report.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

Future<void> showComicMissingComicsDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryProjection projection,
  required Color accent,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => _MissingComicsDialog(
      type: type,
      projection: projection,
      accent: accent,
    ),
  );
}

class _MissingComicsDialog extends StatefulWidget {
  const _MissingComicsDialog({
    required this.type,
    required this.projection,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final LibraryProjection projection;
  final Color accent;

  @override
  State<_MissingComicsDialog> createState() => _MissingComicsDialogState();
}

class _MissingComicsDialogState extends State<_MissingComicsDialog> {
  var _includeVariants = false;
  var _excludeOnOrder = true;
  var _excludeUnreleased = true;
  var _ascending = true;
  var _verbose = false;

  MissingComicReportOptions get _options => MissingComicReportOptions(
        includeVariants: _includeVariants,
        excludeOnOrder: _excludeOnOrder,
        excludeUnreleased: _excludeUnreleased,
        ascending: _ascending,
        verbose: _verbose,
      );

  List<MissingComicSeriesReport> get _reports =>
      buildMissingComicSeriesReports(
        widget.projection.allItems,
        options: _options,
      );

  @override
  Widget build(BuildContext context) {
    final reports = _reports;
    return AccentAlertDialog(
      titlePadding: EdgeInsets.zero,
      title: AccentDialogHeader(
        title: 'Missing comics',
        accent: widget.accent,
        icon: Icons.find_in_page_outlined,
      ),
      content: SizedBox(
        width: 900,
        height: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterChip(
                  label: const Text('Compact'),
                  selected: !_verbose,
                  onSelected: (_) => setState(() => _verbose = false),
                ),
                FilterChip(
                  label: const Text('Verbose'),
                  selected: _verbose,
                  onSelected: (_) => setState(() => _verbose = true),
                ),
                FilterChip(
                  label: const Text('Ascending'),
                  selected: _ascending,
                  onSelected: (_) => setState(() => _ascending = true),
                ),
                FilterChip(
                  label: const Text('Descending'),
                  selected: !_ascending,
                  onSelected: (_) => setState(() => _ascending = false),
                ),
                FilterChip(
                  label: const Text('Variants'),
                  selected: _includeVariants,
                  onSelected: (selected) =>
                      setState(() => _includeVariants = selected),
                ),
                FilterChip(
                  label: const Text('Hide on-order'),
                  selected: _excludeOnOrder,
                  onSelected: (selected) =>
                      setState(() => _excludeOnOrder = selected),
                ),
                FilterChip(
                  label: const Text('Hide unreleased'),
                  selected: _excludeUnreleased,
                  onSelected: (selected) =>
                      setState(() => _excludeUnreleased = selected),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: reports.isEmpty
                  ? Center(
                      child: Text(
                        'No missing comics for the current filters.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: reports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _MissingComicsSeriesCard(
                          type: widget.type,
                          report: report,
                          includeVariants: _includeVariants,
                          verbose: _verbose,
                          accent: widget.accent,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        TextButton.icon(
          onPressed: reports.isEmpty
              ? null
              : () async {
                  final doc = buildMissingComicsPdfDocument(
                    title: 'Missing comics',
                    reports: reports,
                    options: _options,
                  );
                  await Printing.layoutPdf(
                    onLayout: (format) => doc.save(),
                    name: 'missing_comics',
                  );
                },
          icon: const Icon(Icons.print_outlined, size: 16),
          label: const Text('Print / PDF'),
        ),
      ],
    );
  }
}

class _MissingComicsSeriesCard extends StatelessWidget {
  const _MissingComicsSeriesCard({
    required this.type,
    required this.report,
    required this.includeVariants,
    required this.verbose,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final MissingComicSeriesReport report;
  final bool includeVariants;
  final bool verbose;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final compactRanges = formatComicIssueRanges(
      report.issueGroups.map((group) => group.issueNumber),
    );
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: report.coverUrl == null
            ? const Icon(Icons.book_outlined)
            : ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  report.coverUrl!,
                  width: 32,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined),
                ),
              ),
        title: Text(
          report.seriesTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${report.missingIssueCount} missing · ${report.ownedIssueCount} owned',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!verbose)
                  _CompactRangeView(
                    compactRanges: compactRanges,
                    report: report,
                    type: type,
                    accent: accent,
                  )
                else
                  for (final group in report.issueGroups)
                    _VerboseIssueRow(
                      type: type,
                      report: report,
                      group: group,
                      includeVariants: includeVariants,
                      accent: accent,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactRangeView extends StatelessWidget {
  const _CompactRangeView({
    required this.compactRanges,
    required this.report,
    required this.type,
    required this.accent,
  });

  final String compactRanges;
  final MissingComicSeriesReport report;
  final LibraryTypeConfig type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final numbers = report.issueGroups.map((group) => group.issueNumber).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (compactRanges.isNotEmpty)
          Chip(label: Text(compactRanges), visualDensity: VisualDensity.compact),
        for (final number in numbers.take(12))
          ActionChip(
            label: Text(formatComicIssueLabel(number)),
            visualDensity: VisualDensity.compact,
            onPressed: () => _quickAddComicIssue(
              context,
              type: type,
              seriesTitle: report.seriesTitle,
              issueLabel: formatComicIssueLabel(number),
              accent: accent,
            ),
          ),
      ],
    );
  }
}

class _VerboseIssueRow extends StatelessWidget {
  const _VerboseIssueRow({
    required this.type,
    required this.report,
    required this.group,
    required this.includeVariants,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final MissingComicSeriesReport report;
  final MissingComicIssueGroup group;
  final bool includeVariants;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final variantLabels = group.variants
        .map((variant) => variant.variant?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final label = includeVariants && variantLabels.isNotEmpty
        ? '${formatComicIssueLabel(group.issueNumber)} · ${variantLabels.join(' / ')}'
        : formatComicIssueLabel(group.issueNumber);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: includeVariants && variantLabels.isNotEmpty
          ? Text('${variantLabels.length} variant${variantLabels.length == 1 ? '' : 's'}')
          : null,
      trailing: IconButton(
        tooltip: 'Quick add',
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => _quickAddComicIssue(
          context,
          type: type,
          seriesTitle: report.seriesTitle,
          issueLabel: formatComicIssueLabel(group.issueNumber),
          accent: accent,
        ),
      ),
    );
  }
}

Future<void> _quickAddComicIssue(
  BuildContext context, {
  required LibraryTypeConfig type,
  required String seriesTitle,
  required String issueLabel,
  required Color accent,
}) async {
  await showLibraryAddDialog(
    context: context,
    type: type,
    accent: accent,
    initialQuery: '$seriesTitle $issueLabel',
  );
}
