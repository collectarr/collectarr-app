import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/settings/tmdb_import_service.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';

enum TmdbImportPreviewFilter {
  all,
  unmatched,
  matched,
}

Future<String?> showTmdbImportPreviewDialog({
  required BuildContext context,
  required TmdbImportPreview preview,
  required String sourceLabel,
  required bool keepUnmatchedLocally,
  required bool hasApiKey,
  required String importButtonLabel,
  required Future<String> Function({required bool skipUnmatchedRows}) onImport,
  required String Function(Object error) mapImportError,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return _TmdbImportPreviewDialog(
        preview: preview,
        sourceLabel: sourceLabel,
        keepUnmatchedLocally: keepUnmatchedLocally,
        hasApiKey: hasApiKey,
        importButtonLabel: importButtonLabel,
        onImport: onImport,
        mapImportError: mapImportError,
      );
    },
  );
}

class _TmdbImportPreviewDialog extends StatefulWidget {
  const _TmdbImportPreviewDialog({
    required this.preview,
    required this.sourceLabel,
    required this.keepUnmatchedLocally,
    required this.hasApiKey,
    required this.importButtonLabel,
    required this.onImport,
    required this.mapImportError,
  });

  final TmdbImportPreview preview;
  final String sourceLabel;
  final bool keepUnmatchedLocally;
  final bool hasApiKey;
  final String importButtonLabel;
  final Future<String> Function({required bool skipUnmatchedRows}) onImport;
  final String Function(Object error) mapImportError;

  @override
  State<_TmdbImportPreviewDialog> createState() =>
      _TmdbImportPreviewDialogState();
}

class _TmdbImportPreviewDialogState extends State<_TmdbImportPreviewDialog> {
  TmdbImportPreviewFilter _filter = TmdbImportPreviewFilter.all;
  bool _isImporting = false;
  bool _skipUnmatchedRows = false;

  @override
  Widget build(BuildContext context) {
    final preview = widget.preview;
    final unmatchedCount = preview.unmatched.length;
    final viewSize = MediaQuery.sizeOf(context);
    final dialogWidth =
        (viewSize.width - 48).clamp(320.0, 820.0).toDouble();
    final dialogHeight =
        (viewSize.height - 96).clamp(360.0, 560.0).toDouble();
    return AccentAlertDialog(
      insetPadding: const EdgeInsets.all(24),
      title: Text(preview.collection.label),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.sourceLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (!widget.hasApiKey) ...[
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No TMDB API key configured. Imported items will have minimal metadata '
                          '(title and year only). Add an API key in the TMDB settings to get full '
                          'details (synopsis, genres, poster, credits).',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (unmatchedCount > 0) ...[
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${preview.unmatched.length} unmatched rows will create metadata proposals.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile.adaptive(
                          value: _skipUnmatchedRows,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Skip unmatched rows'),
                          subtitle: Text(
                            widget.keepUnmatchedLocally
                                ? 'Only matched rows will import. Unmatched rows will be skipped instead of creating proposals or local copies.'
                                : 'Only matched rows will import. Unmatched rows will be skipped instead of creating proposals.',
                          ),
                          onChanged: _isImporting
                              ? null
                              : (value) {
                                  setState(() {
                                    _skipUnmatchedRows = value ?? false;
                                  });
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Expanded(
              child: _TmdbImportPreviewPanel(
                preview: preview,
                keepUnmatchedLocally: widget.keepUnmatchedLocally,
                skipUnmatchedRows: _skipUnmatchedRows,
                filter: _filter,
                onFilterChanged: (nextFilter) {
                  setState(() {
                    _filter = nextFilter;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        FilledButton.icon(
          onPressed: _isImporting
              ? null
              : () async {
                  setState(() {
                    _isImporting = true;
                  });
                  try {
                    final resultMessage = await widget.onImport(
                      skipUnmatchedRows: _skipUnmatchedRows,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop(resultMessage);
                  } catch (error) {
                    if (!context.mounted) {
                      return;
                    }
                    setState(() {
                      _isImporting = false;
                    });
                    showAppToast(
                      context,
                      widget.mapImportError(error),
                      tone: AppToastTone.error,
                    );
                  }
                },
          icon: _isImporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_done_outlined),
          label: Text(widget.importButtonLabel),
        ),
      ],
    );
  }
}

class _TmdbImportPreviewPanel extends StatelessWidget {
  const _TmdbImportPreviewPanel({
    required this.preview,
    required this.keepUnmatchedLocally,
    required this.skipUnmatchedRows,
    required this.filter,
    required this.onFilterChanged,
  });

  final TmdbImportPreview preview;
  final bool keepUnmatchedLocally;
  final bool skipUnmatchedRows;
  final TmdbImportPreviewFilter filter;
  final ValueChanged<TmdbImportPreviewFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final matched = preview.matched;
    final unmatched = preview.unmatched;
    final importModeLabel = preview.collection == TmdbImportCollection.ratedMovies
        ? 'Completed'
        : 'Wishlist';
    final unmatchedModeLabel = skipUnmatchedRows
        ? 'Unmatched: skipped'
        : keepUnmatchedLocally
            ? 'Unmatched: local + proposal'
            : 'Unmatched: proposal only';
    final visibleMatches = switch (filter) {
      TmdbImportPreviewFilter.all => preview.matches,
      TmdbImportPreviewFilter.unmatched => unmatched,
      TmdbImportPreviewFilter.matched => matched,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PreviewCountChip(label: 'Rows', value: preview.matches.length),
            _PreviewCountChip(label: 'Matched', value: matched.length),
            _PreviewCountChip(label: 'Unmatched', value: unmatched.length),
            _PreviewCountChip(label: 'Import', valueText: importModeLabel),
            _PreviewCountChip(label: 'Mode', valueText: unmatchedModeLabel),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<TmdbImportPreviewFilter>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment<TmdbImportPreviewFilter>(
                value: TmdbImportPreviewFilter.all,
                label: Text('All ${preview.matches.length}'),
              ),
              ButtonSegment<TmdbImportPreviewFilter>(
                value: TmdbImportPreviewFilter.unmatched,
                label: Text('Unmatched ${unmatched.length}'),
              ),
              ButtonSegment<TmdbImportPreviewFilter>(
                value: TmdbImportPreviewFilter.matched,
                label: Text('Matched ${matched.length}'),
              ),
            ],
            selected: {filter},
            onSelectionChanged: (selection) {
              final nextFilter = selection.firstOrNull;
              if (nextFilter != null) {
                onFilterChanged(nextFilter);
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: visibleMatches.isEmpty
                ? _TmdbPreviewFilterEmptyState(filter: filter)
                : ListView.separated(
                    itemCount: visibleMatches.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final match = visibleMatches[index];
                      final item = match.catalogItem;
                      final subtitle = item == null
                          ? skipUnmatchedRows
                              ? 'Skipped'
                              : keepUnmatchedLocally
                                  ? 'Proposal + local copy'
                                  : 'Proposal only'
                          : 'Core: ${item.title}${item.releaseYear == null ? '' : ' (${item.releaseYear})'}';
                      final statusLabel = item == null
                          ? (skipUnmatchedRows ? 'Skip' : 'New')
                          : 'Match';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item == null
                                  ? (skipUnmatchedRows
                                      ? Icons.skip_next_outlined
                                      : Icons.outbox_outlined)
                                  : Icons.check_circle_outline,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    match.entry.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _PreviewTag(label: statusLabel),
                            if (preview.collection ==
                                    TmdbImportCollection.ratedMovies &&
                                match.entry.rating != null) ...[
                              const SizedBox(width: 6),
                              _PreviewTag(
                                label: '${match.entry.rating!.round()}/10',
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _TmdbPreviewFilterEmptyState extends StatelessWidget {
  const _TmdbPreviewFilterEmptyState({required this.filter});

  final TmdbImportPreviewFilter filter;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      TmdbImportPreviewFilter.all => 'No preview rows',
      TmdbImportPreviewFilter.unmatched => 'No unmatched rows',
      TmdbImportPreviewFilter.matched => 'No matched rows',
    };
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _PreviewCountChip extends StatelessWidget {
  const _PreviewCountChip({
    required this.label,
    this.value,
    this.valueText,
  }) : assert(value != null || valueText != null);

  final String label;
  final int? value;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    final displayValue = valueText ?? '$value';
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text('$label: $displayValue'),
    );
  }
}

class _PreviewTag extends StatelessWidget {
  const _PreviewTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(label, style: theme.textTheme.labelSmall),
      ),
    );
  }
}