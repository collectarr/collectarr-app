import 'package:collectarr_app/ui/app_icons.dart';

import 'package:collectarr_app/features/settings/settings_connection_diagnostics.dart';
import 'package:collectarr_app/features/sync/presentation/sync_conflict_review.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ---------------------------------------------------------------------------
// Connection tab widgets: pairing, diagnostics, sync status, conflicts
// ---------------------------------------------------------------------------

class SettingsPairingCodeDialog extends StatefulWidget {
  const SettingsPairingCodeDialog({super.key});

  @override
  State<SettingsPairingCodeDialog> createState() =>
      _SettingsPairingCodeDialogState();
}

class _SettingsPairingCodeDialogState extends State<SettingsPairingCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      headerIcon: AppIcons.sync,
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

class SettingsPairingQrDialog extends StatelessWidget {
  const SettingsPairingQrDialog({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AccentAlertDialog(
      headerIcon: AppIcons.sync,
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

class SettingsSyncWebWarning extends StatelessWidget {
  const SettingsSyncWebWarning({super.key});

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

class SettingsDiagnosticRow extends StatelessWidget {
  const SettingsDiagnosticRow(
      {super.key, required this.diagnostic, required this.idleLabel});

  final SettingsDiagnosticState? diagnostic;
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

class SettingsStatusChip extends StatelessWidget {
  const SettingsStatusChip({
    super.key,
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

class SettingsSyncServiceSummary extends StatelessWidget {
  const SettingsSyncServiceSummary({
    super.key,
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
                SettingsStatusChip(
                  icon: Icons.storage_outlined,
                  label: '${status['entity_count'] ?? '-'} entities',
                ),
                SettingsStatusChip(
                  icon: Icons.account_tree_outlined,
                  label: 'protocol ${status['protocol_version'] ?? '-'}',
                ),
                SettingsStatusChip(
                  icon: Icons.delete_sweep_outlined,
                  label: '${status['tombstone_count'] ?? '-'} tombstones',
                ),
                SettingsStatusChip(
                  icon: Icons.history,
                  label: '${status['change_count'] ?? '-'} events',
                ),
                SettingsStatusChip(
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

class SettingsSyncConflictSummary extends StatelessWidget {
  const SettingsSyncConflictSummary({super.key, required this.count});

  final int count;

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
        child: Row(
          children: [
            Icon(Icons.sync_problem_outlined, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                count == 1
                    ? '1 sync conflict needs a decision'
                    : '$count sync conflicts need a decision',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton(
              onPressed: () => showSyncConflictReview(context),
              child: const Text('Review'),
            ),
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
