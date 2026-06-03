part of 'settings_page.dart';

// ---------------------------------------------------------------------------
// Connection tab widgets: pairing, diagnostics, sync status, conflicts
// ---------------------------------------------------------------------------

class _PairingCodeDialog extends StatefulWidget {
  const _PairingCodeDialog();

  @override
  State<_PairingCodeDialog> createState() => _PairingCodeDialogState();
}

class _PairingCodeDialogState extends State<_PairingCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      title: const Text('Apply pairing code'),
      content: SizedBox(
        width: 520,
        child: TextField(
          controller: _controller,
          autofocus: true,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Pairing code',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _PairingQrDialog extends StatelessWidget {
  const _PairingQrDialog({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AccentAlertDialog(
      title: const Text('Pairing QR'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: code,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              code,
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
          child: const Text('Copy code'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SyncWebWarning extends StatelessWidget {
  const _SyncWebWarning();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.32),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.42)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.public_off_outlined,
              color: colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Web sync uses your personal sync endpoint directly. Browser CORS, HTTPS, and local-network access rules can block it even when desktop or mobile sync works.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({required this.diagnostic, required this.idleLabel});

  final _DiagnosticState? diagnostic;
  final String idleLabel;

  @override
  Widget build(BuildContext context) {
    final state = diagnostic;
    if (state == null) {
      return _DiagnosticPill(
        icon: Icons.radio_button_unchecked,
        label: idleLabel,
      );
    }
    if (state.isChecking) {
      return const _DiagnosticPill(
        icon: Icons.sync,
        label: 'Checking...',
      );
    }
    return _DiagnosticPill(
      icon: state.isOk ? Icons.check_circle_outline : Icons.error_outline,
      label: state.message,
      isError: !state.isOk,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    this.isError = false,
  });

  final IconData icon;
  final String label;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: isError ? colorScheme.error : colorScheme.primary,
      ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SyncServiceSummary extends StatelessWidget {
  const _SyncServiceSummary({
    required this.status,
    required this.devices,
  });

  final Map<String, dynamic> status;
  final List<Map<String, dynamic>> devices;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  icon: Icons.storage_outlined,
                  label: '${status['entity_count'] ?? '-'} entities',
                ),
                _StatusChip(
                  icon: Icons.account_tree_outlined,
                  label: 'protocol ${status['protocol_version'] ?? '-'}',
                ),
                _StatusChip(
                  icon: Icons.delete_sweep_outlined,
                  label: '${status['tombstone_count'] ?? '-'} tombstones',
                ),
                _StatusChip(
                  icon: Icons.history,
                  label: '${status['change_count'] ?? '-'} events',
                ),
                _StatusChip(
                  icon: Icons.event_repeat,
                  label: '${status['retention_days'] ?? '-'}d retention',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Devices seen', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            if (devices.isEmpty)
              const Text('No synced devices yet.')
            else
              for (final device in devices.take(5))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.devices_other, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${device['device_id']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('${device['change_count'] ?? 0} events'),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SyncConflictSummary extends StatelessWidget {
  const _SyncConflictSummary({
    required this.changes,
    required this.onKeepLocal,
    required this.onDismiss,
    required this.onDismissAll,
  });

  final List<SyncRejectedChange> changes;
  final Future<void> Function(SyncRejectedChange change) onKeepLocal;
  final ValueChanged<SyncRejectedChange> onDismiss;
  final VoidCallback onDismissAll;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.28),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.36)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.sync_problem_outlined, color: colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sync conflict review',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: onDismissAll,
                  icon: const Icon(Icons.done_all_outlined),
                  label: const Text('Keep service'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Use Keep local when this device should overwrite the service on the next sync. Use Keep service when the service version is correct.',
            ),
            const SizedBox(height: 8),
            for (final change in changes.take(5))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.rule_folder_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${change.entityType}:${_shortSyncId(change.entityId)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _conflictLabel(change),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'View payload diff',
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) =>
                            _SyncConflictDiffDialog(change: change),
                      ),
                      icon: const Icon(Icons.difference_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Copy conflict id',
                      onPressed: () => Clipboard.setData(
                        ClipboardData(text: change.key),
                      ),
                      icon: const Icon(Icons.copy_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Keep local version',
                      onPressed: () => onKeepLocal(change),
                      icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Keep service version',
                      onPressed: () => onDismiss(change),
                      icon: const Icon(Icons.check_outlined, size: 18),
                    ),
                  ],
                ),
              ),
            if (changes.length > 5)
              Text('+${changes.length - 5} older rejected changes'),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticPill extends StatelessWidget {
  const _DiagnosticPill({
    required this.icon,
    required this.label,
    this.isError = false,
  });

  final IconData icon;
  final String label;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isError ? colorScheme.error : colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SyncConflictDiffDialog extends StatelessWidget {
  const _SyncConflictDiffDialog({required this.change});

  final SyncRejectedChange change;

  @override
  Widget build(BuildContext context) {
    final localPayload = change.localPayload ?? const <String, dynamic>{};
    final servicePayload = change.servicePayload ?? const <String, dynamic>{};
    return AccentAlertDialog(
      title: const Text('Sync conflict diff'),
      content: SizedBox(
        width: 860,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ConflictDiffChip(label: change.entityType),
                  _ConflictDiffChip(label: _shortSyncId(change.entityId)),
                  _ConflictDiffChip(label: change.reason),
                  if (change.localAction != null)
                    _ConflictDiffChip(label: 'local ${change.localAction}'),
                  if (change.serviceAction != null)
                    _ConflictDiffChip(
                      label: 'service ${change.serviceAction}',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final panels = [
                    _PayloadPanel(
                      title: 'Local rejected payload',
                      timestamp: change.localClientChangedAt,
                      payload: localPayload,
                    ),
                    _PayloadPanel(
                      title: 'Service kept payload',
                      timestamp: change.currentClientChangedAt,
                      payload: servicePayload,
                    ),
                  ];
                  if (constraints.maxWidth < 720) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        panels[0],
                        const SizedBox(height: 12),
                        panels[1],
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: panels[0]),
                      const SizedBox(width: 12),
                      Expanded(child: panels[1]),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _PayloadPanel extends StatelessWidget {
  const _PayloadPanel({
    required this.title,
    required this.payload,
    this.timestamp,
  });

  final String title;
  final DateTime? timestamp;
  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final encoded = const JsonEncoder.withIndent('  ').convert(payload);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatProposalTime(timestamp!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            SelectableText(
              encoded,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictDiffChip extends StatelessWidget {
  const _ConflictDiffChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

String _shortSyncId(String id) {
  if (id.length <= 8) {
    return id;
  }
  return id.substring(0, 8);
}

String _conflictLabel(SyncRejectedChange change) {
  final label = SyncWarningFormatter.reasonLabel(change.reason);
  final current = change.currentClientChangedAt;
  if (current == null) {
    return label;
  }
  return '$label, service kept ${_formatProposalTime(current)}';
}

class _DiagnosticState {
  const _DiagnosticState.checking()
      : isChecking = true,
        isOk = false,
        message = '';

  const _DiagnosticState.ok(this.message)
      : isChecking = false,
        isOk = true;

  const _DiagnosticState.error(this.message)
      : isChecking = false,
        isOk = false;

  final bool isChecking;
  final bool isOk;
  final String message;
}
