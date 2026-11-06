import 'dart:convert';

import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _noValue = '—';
const _maxDifferences = 8;

Future<void> showSyncConflictReview(BuildContext context) {
  return showAppDialog<void>(
    context: context,
    builder: (_) => const SyncConflictReviewDialog(),
  );
}

/// Lets the user choose, per item, which device's version the sync service keeps.
class SyncConflictReviewDialog extends ConsumerWidget {
  const SyncConflictReviewDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      syncControllerProvider.select((sync) => sync.rejectedChanges.isEmpty),
      (_, isEmpty) {
        if (isEmpty) Navigator.of(context).pop();
      },
    );
    final sync = ref.watch(syncControllerProvider);
    final controller = ref.read(syncControllerProvider.notifier);
    final changes = sync.rejectedChanges;
    return AccentAlertDialog(
      headerIcon: AppIcons.sync,
      title: const Text('Sync conflicts'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Another device changed these items too. The service kept the '
                'other version; choose which one to keep.',
              ),
              for (final change in changes) ...[
                const SizedBox(height: 12),
                _ConflictCard(
                  change: change,
                  isBusy: sync.isSyncing,
                  onKeepLocal: () => controller.keepLocalRejectedChange(change),
                  onKeepOther: () =>
                      controller.dismissRejectedChange(change.key),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (changes.length > 1)
          TextButton(
            onPressed:
                sync.isSyncing ? null : controller.dismissAllRejectedChanges,
            child: const Text('Keep all other versions'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({
    required this.change,
    required this.isBusy,
    required this.onKeepLocal,
    required this.onKeepOther,
  });

  final SyncRejectedChange change;
  final bool isBusy;
  final VoidCallback onKeepLocal;
  final VoidCallback onKeepOther;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final differences = syncConflictDifferences(change);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(syncConflictTitle(change), style: theme.textTheme.titleSmall),
            for (final difference in differences.take(_maxDifferences)) ...[
              const SizedBox(height: 8),
              Text(difference.field, style: theme.textTheme.labelMedium),
              Text(
                'This device: ${difference.local}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Other version: ${difference.other}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (differences.length > _maxDifferences) ...[
              const SizedBox(height: 8),
              Text(
                '+${differences.length - _maxDifferences} more differences',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                if (change.canKeepLocal)
                  TextButton(
                    onPressed: isBusy ? null : onKeepLocal,
                    child: const Text('Keep this device'),
                  ),
                TextButton(
                  onPressed: isBusy ? null : onKeepOther,
                  child: const Text('Keep other version'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A name the user recognizes, from whichever payload still describes the item.
String syncConflictTitle(SyncRejectedChange change) {
  for (final payload in [change.localPayload, change.servicePayload]) {
    if (payload == null) continue;
    final catalog = payload['catalog_data'];
    final fields = catalog is Map ? catalog : payload;
    final title = _text(fields['title']) ?? _text(fields['name']);
    if (title != null) return title;
    final series = _text(fields['series_title']);
    if (series != null) {
      final issue = _text(fields['issue_number']);
      return issue == null ? series : '$series #$issue';
    }
    final value = _text(fields['value']);
    if (value != null) return value;
  }
  return change.entityType.replaceAll('_', ' ');
}

String? _text(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class SyncConflictDifference {
  const SyncConflictDifference({
    required this.field,
    required this.local,
    required this.other,
  });

  final String field;
  final String local;
  final String other;
}

/// The fields the two versions disagree on, in a form a person can compare.
List<SyncConflictDifference> syncConflictDifferences(
  SyncRejectedChange change,
) {
  if (change.localAction == 'delete') {
    return const [
      SyncConflictDifference(
        field: 'Item',
        local: 'Removed',
        other: 'Kept',
      ),
    ];
  }
  if (change.serviceAction == 'delete') {
    return const [
      SyncConflictDifference(
        field: 'Item',
        local: 'Kept',
        other: 'Removed',
      ),
    ];
  }
  final local = <String, String>{};
  final other = <String, String>{};
  _flatten(change.localPayload ?? const {}, local);
  _flatten(change.servicePayload ?? const {}, other);
  return [
    for (final path in {...local.keys, ...other.keys})
      if (local[path] != other[path])
        SyncConflictDifference(
          field: _fieldLabel(path),
          local: local[path] ?? _noValue,
          other: other[path] ?? _noValue,
        ),
  ];
}

void _flatten(Map<dynamic, dynamic> source, Map<String, String> into,
    [String prefix = '']) {
  for (final entry in source.entries) {
    final key = entry.key.toString();
    if (key == 'kind' || (prefix.isEmpty && key == 'updated_at')) continue;
    final path = prefix.isEmpty ? key : '$prefix.$key';
    final value = entry.value;
    if (value is Map) {
      _flatten(value, into, path);
    } else if (value != null) {
      into[path] = value is String ? value : jsonEncode(value);
    }
  }
}

String _fieldLabel(String path) {
  final words = path.split('.').last.replaceAll('_', ' ');
  return '${words[0].toUpperCase()}${words.substring(1)}';
}
