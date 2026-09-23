import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/tracking/session_history_presenter.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_topology.dart';
export 'package:collectarr_app/features/library/tracking/library_tracking_topology.dart'
    show LibraryTrackingSessionLabels;

class WatchHistoryTargetOption {
  const WatchHistoryTargetOption({
    required this.ref,
    required this.label,
    this.subtitle,
  });

  final CatalogEntityRef ref;
  final String label;
  final String? subtitle;
}

class WatchHistorySection extends ConsumerWidget {
  const WatchHistorySection({
    super.key,
    required this.catalogRef,
    required this.accent,
    this.labels = LibraryTrackingSessionLabels.watch,
    this.defaultTargetRef,
    this.targetOptions = const <WatchHistoryTargetOption>[],
  });

  final Color accent;
  final CatalogEntityRef catalogRef;
  final LibraryTrackingSessionLabels labels;
  final CatalogEntityRef? defaultTargetRef;
  final List<WatchHistoryTargetOption> targetOptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(watchSessionsByCatalogRefProvider(catalogRef));
    final runSummary = const SessionHistoryPresenter().build(sessions);
    final palette = appPalette(context);
    final resolvedTargets = _resolvedTargetOptions();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        border: Border.all(color: accent.withValues(alpha: 0.33)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    labels.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: accent, size: 22),
                  tooltip: labels.addTooltip,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => _showEditor(context, ref,
                      resolvedTargets: resolvedTargets),
                ),
              ],
            ),
            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  labels.emptyText,
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
              )
            else ...[
              const SizedBox(height: 4),
              if (runSummary.rewatchCount > 0) ...[
                Text(
                  runSummary.label(
                    nounSingular: labels.nounSingular,
                    nounPlural: labels.nounPlural,
                  ),
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                '${sessions.length} ${sessions.length == 1 ? labels.nounSingular : labels.nounPlural}',
                style: TextStyle(color: palette.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              for (final session in sessions)
                _WatchSessionTile(
                  session: session,
                  accent: accent,
                  sessionIcon: labels.icon,
                  targetLabel:
                      _targetLabelFor(session.targetRef, resolvedTargets),
                  onEdit: () => _showEditor(
                    context,
                    ref,
                    resolvedTargets: resolvedTargets,
                    existing: session,
                  ),
                  onDelete: () => ref
                      .read(watchSessionMutationsProvider)
                      .removeWatchSession(session),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<WatchHistoryTargetOption> _resolvedTargetOptions() {
    if (targetOptions.isNotEmpty) {
      return targetOptions;
    }
    final fallbackRef = defaultTargetRef ?? catalogRef;
    return [
      WatchHistoryTargetOption(
        ref: fallbackRef,
        label: 'Current item',
      ),
    ];
  }

  String _targetLabelFor(
    CatalogEntityRef targetRef,
    List<WatchHistoryTargetOption> options,
  ) {
    for (final option in options) {
      if (option.ref == targetRef) {
        return option.label;
      }
    }
    return targetRef.id;
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, {
    required List<WatchHistoryTargetOption> resolvedTargets,
    WatchSession? existing,
  }) async {
    final result = await showDialog<_WatchSessionDraft>(
      context: context,
      builder: (_) => _WatchSessionDialog(
        accent: accent,
        title: existing == null ? labels.title : 'Edit ${labels.nounSingular}',
        confirmLabel: existing == null ? 'Add' : 'Save',
        targetOptions: resolvedTargets,
        initialTarget: _initialTargetFor(existing, resolvedTargets),
        initialWatchedAt: existing?.watchedAt ?? DateTime.now().toUtc(),
        initialSeenWhere: existing?.seenWhere,
        initialRating: existing?.rating,
        initialNotes: existing?.notes,
      ),
    );
    if (result == null || !context.mounted) {
      return;
    }
    await ref.read(watchSessionMutationsProvider).addWatchSession(
          result.target.ref,
          id: existing?.id,
          watchedAt: result.watchedAt,
          seenWhere: result.seenWhere,
          rating: result.rating,
          notes: result.notes,
        );
  }

  WatchHistoryTargetOption _initialTargetFor(
    WatchSession? existing,
    List<WatchHistoryTargetOption> options,
  ) {
    if (existing != null) {
      for (final option in options) {
        if (option.ref == existing.targetRef) {
          return option;
        }
      }
      return WatchHistoryTargetOption(
        ref: existing.targetRef,
        label: _targetLabelFor(existing.targetRef, options),
      );
    }
    return options.first;
  }
}

class _WatchSessionTile extends StatelessWidget {
  const _WatchSessionTile({
    required this.session,
    required this.accent,
    required this.sessionIcon,
    required this.targetLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final WatchSession session;
  final Color accent;
  final IconData sessionIcon;
  final String targetLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final localDate = session.watchedAt.toLocal();
    final dateLabel =
        '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
    final timeLabel =
        '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: palette.surfaceSubtle.withValues(alpha: 0.82),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: accent.withValues(alpha: 0.14)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(sessionIcon, color: accent, size: 18),
          title: Text(
            '$dateLabel • $timeLabel',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                targetLabel,
                style: TextStyle(color: palette.textMuted, fontSize: 12),
              ),
              if (session.seenWhere != null &&
                  session.seenWhere!.trim().isNotEmpty)
                Text(
                  session.seenWhere!,
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
              if (session.rating != null)
                Text(
                  '${session.rating}/10',
                  style: TextStyle(color: accent, fontSize: 12),
                ),
              if (session.notes != null && session.notes!.trim().isNotEmpty)
                Text(
                  session.notes!,
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
            ],
          ),
          trailing: Wrap(
            spacing: 0,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 18, color: palette.textMuted),
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 18, color: palette.textMuted),
                tooltip: 'Delete',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WatchSessionDraft {
  const _WatchSessionDraft({
    required this.target,
    required this.watchedAt,
    required this.seenWhere,
    required this.rating,
    required this.notes,
  });

  final WatchHistoryTargetOption target;
  final DateTime watchedAt;
  final String? seenWhere;
  final int? rating;
  final String? notes;
}

class _WatchSessionDialog extends StatefulWidget {
  const _WatchSessionDialog({
    required this.accent,
    required this.title,
    required this.confirmLabel,
    required this.targetOptions,
    required this.initialTarget,
    required this.initialWatchedAt,
    required this.initialSeenWhere,
    required this.initialRating,
    required this.initialNotes,
  });

  final Color accent;
  final String title;
  final String confirmLabel;
  final List<WatchHistoryTargetOption> targetOptions;
  final WatchHistoryTargetOption initialTarget;
  final DateTime initialWatchedAt;
  final String? initialSeenWhere;
  final int? initialRating;
  final String? initialNotes;

  @override
  State<_WatchSessionDialog> createState() => _WatchSessionDialogState();
}

class _WatchSessionDialogState extends State<_WatchSessionDialog> {
  late WatchHistoryTargetOption _selectedTarget;
  late DateTime _watchedAt;
  late final TextEditingController _seenWhereController;
  late final TextEditingController _ratingController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _selectedTarget = widget.initialTarget;
    _watchedAt = widget.initialWatchedAt;
    _seenWhereController =
        TextEditingController(text: widget.initialSeenWhere ?? '');
    _ratingController =
        TextEditingController(text: widget.initialRating?.toString() ?? '');
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _seenWhereController.dispose();
    _ratingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      titlePadding: EdgeInsets.zero,
      title: AccentDialogHeader(
        title: widget.title,
        icon: Icons.history,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.targetOptions.isNotEmpty) ...[
              CompactSearchDropdownFormField<WatchHistoryTargetOption>(
                initialValue: _selectedTarget,
                decoration: const InputDecoration(labelText: 'Target'),
                items: [
                  for (final option in widget.targetOptions)
                    DropdownMenuItem(
                      value: option,
                      child: Text(
                        option.subtitle == null
                            ? option.label
                            : '${option.label} • ${option.subtitle}',
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _selectedTarget = value);
                },
              ),
              const SizedBox(height: 12),
            ],
            Column(
              children: [
                LibraryDateFieldButton(
                  label: 'Date',
                  value: _watchedAt.toLocal(),
                  onChanged: (picked) {
                    if (picked == null) return;
                    final local = _watchedAt.toLocal();
                    setState(() {
                      _watchedAt = DateTime.utc(
                        picked.year,
                        picked.month,
                        picked.day,
                        local.hour,
                        local.minute,
                      );
                    });
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_watchedAt.toLocal()),
                    );
                    if (picked == null || !context.mounted) return;
                    final local = _watchedAt.toLocal();
                    setState(() {
                      _watchedAt = DateTime.utc(
                        local.year,
                        local.month,
                        local.day,
                        picked.hour,
                        picked.minute,
                      );
                    });
                  },
                  icon: const Icon(Icons.schedule_outlined, size: 16),
                  label: Text(
                    'Time: ${TimeOfDay.fromDateTime(_watchedAt.toLocal()).format(context)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _seenWhereController,
              decoration: const InputDecoration(labelText: 'Seen where'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ratingController,
              decoration: const InputDecoration(labelText: 'Rating (0-10)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final ratingText = _ratingController.text.trim();
            final rating = ratingText.isEmpty ? null : int.tryParse(ratingText);
            Navigator.pop(
              context,
              _WatchSessionDraft(
                target: _selectedTarget,
                watchedAt: _watchedAt,
                seenWhere: _seenWhereController.text.trim().isEmpty
                    ? null
                    : _seenWhereController.text.trim(),
                rating: rating,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              ),
            );
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
