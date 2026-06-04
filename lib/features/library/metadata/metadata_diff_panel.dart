import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

class MetadataDiffEntry {
  const MetadataDiffEntry({
    required this.label,
    required this.localValue,
    required this.serverValue,
    this.onAccept,
  });

  final String label;
  final String localValue;
  final String serverValue;
  final VoidCallback? onAccept;

  bool get isDifferent => localValue.trim() != serverValue.trim();
}

class MetadataDiffPanel extends StatelessWidget {
  const MetadataDiffPanel({
    super.key,
    required this.title,
    required this.entries,
    this.onAcceptAll,
    this.emptyText = 'No differences found.',
  });

  final String title;
  final List<MetadataDiffEntry> entries;
  final VoidCallback? onAcceptAll;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final differing = entries.where((entry) => entry.isDifferent).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kEditPanelRaised,
        border: Border.all(color: kEditDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (onAcceptAll != null && differing.isNotEmpty)
                TextButton.icon(
                  onPressed: onAcceptAll,
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('Apply all'),
                ),
            ],
          ),
          if (differing.isEmpty)
            Text(
              emptyText,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: kEditTextMuted),
            )
          else
            Column(
              children: [
                for (final entry in differing) ...[
                  const SizedBox(height: 6),
                  _MetadataDiffRow(entry: entry),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _MetadataDiffRow extends StatelessWidget {
  const _MetadataDiffRow({required this.entry});

  final MetadataDiffEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kAppField,
        border: Border.all(color: kEditDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DiffValue(
                  label: 'Local',
                  value: entry.localValue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DiffValue(
                  label: 'Server',
                  value: entry.serverValue,
                ),
              ),
              if (entry.onAccept != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Apply server value',
                  icon: const Icon(Icons.arrow_back, size: 16),
                  onPressed: entry.onAccept,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DiffValue extends StatelessWidget {
  const _DiffValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: kEditTextMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '—' : value,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
