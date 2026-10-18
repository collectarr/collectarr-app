import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup_controller.dart';
import 'package:collectarr_app/features/settings/local_database_maintenance.dart';
import 'package:collectarr_app/features/settings/settings_layout.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings > Data > Automatic backups: daily time-stamped copies of the
/// database, how long they are kept, and restoring one of them.
class SettingsAutomaticBackupsPanel extends ConsumerStatefulWidget {
  const SettingsAutomaticBackupsPanel({super.key});

  @override
  ConsumerState<SettingsAutomaticBackupsPanel> createState() =>
      _SettingsAutomaticBackupsPanelState();
}

class _SettingsAutomaticBackupsPanelState
    extends ConsumerState<SettingsAutomaticBackupsPanel> {
  AutomaticBackupController get _controller =>
      ref.read(automaticBackupProvider.notifier);

  @override
  void initState() {
    super.initState();
    if (_controller.isSupported) _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isSupported) {
      return const SettingsPanel(
        icon: Icons.history,
        title: 'Automatic backups',
        child: Text(
          'Automatic backups are kept by the desktop and mobile apps. In the '
          'browser, use Backup to JSON below.',
        ),
      );
    }
    final backups = ref.watch(automaticBackupProvider);
    final desktop = !kIsWeb &&
        const {
          TargetPlatform.windows,
          TargetPlatform.macOS,
          TargetPlatform.linux,
        }.contains(defaultTargetPlatform);
    return SettingsPanel(
      icon: Icons.history,
      title: 'Automatic backups',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Collectarr copies the whole database, covers and images included, '
            'once a day when it starts and before a restore or a clear '
            'replaces your data. Restore any copy below.',
          ),
          const SizedBox(height: 12),
          SettingsCheck(
            key: const Key('settings.backups.automatic'),
            label: 'Back up automatically once a day',
            value: backups.enabled,
            onChanged: (value) => _controller.setEnabled(value),
          ),
          const SizedBox(height: 10),
          const SettingsLegend('Keep backups for'),
          SettingsSelect<int>(
            value: backups.keepDays,
            values: automaticBackupKeepDaysOptions,
            labelOf: _keepDaysLabel,
            onChanged: (days) => _controller.setKeepDays(days),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.tonalIcon(
              key: const Key('settings.backups.now'),
              onPressed: backups.busy ? null : _backUpNow,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Back up now'),
            ),
            if (desktop)
              OutlinedButton.icon(
                onPressed: _openFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open backups folder'),
              ),
          ]),
          const SizedBox(height: 12),
          if (backups.backups.isEmpty)
            const Text('No backups yet.')
          else
            for (final backup in backups.backups)
              _BackupRow(
                backup: backup,
                onRestore: backups.busy ? null : () => _restore(backup),
              ),
        ],
      ),
    );
  }

  Future<void> _backUpNow() async {
    try {
      await _controller.backUp();
      showSettingsToast('Backup saved', tone: AppToastTone.success);
    } catch (error) {
      showSettingsToast('Backup failed: ${describeSettingsError(error)}',
          tone: AppToastTone.error);
    }
  }

  Future<void> _openFolder() async {
    final path = await _controller.folderPath();
    if (!await launchUrl(Uri.directory(path))) {
      showSettingsToast('Backups are in $path');
    }
  }

  Future<void> _restore(AutomaticBackup backup) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (dialogContext) => AccentAlertDialog(
        headerIcon: AppIcons.backupRestore,
        title: const Text('Restore backup'),
        content: Text(
          'Replace all local data with the backup from '
          '${formatSettingsTime(backup.createdAt)}? Your current data is '
          'backed up first, so this restore can itself be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('settings.backups.restore.confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final data = await _controller.read(backup);
      await _controller.backUp(reason: AutomaticBackupReason.beforeRestore);
      if (!mounted) return;
      await LocalDatabaseMaintenanceCoordinator(ref).restore(data);
      showSettingsToast('Backup restored', tone: AppToastTone.success);
    } catch (error) {
      showSettingsToast('Restore failed: ${describeSettingsError(error)}',
          tone: AppToastTone.error);
    }
  }
}

String _keepDaysLabel(int days) => switch (days) {
      0 => 'Forever',
      7 => '1 week',
      14 => '2 weeks',
      30 => '30 days',
      90 => '3 months',
      365 => '1 year',
      _ => '$days days',
    };

class _BackupRow extends StatelessWidget {
  const _BackupRow({required this.backup, required this.onRestore});

  final AutomaticBackup backup;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final details = [
      formatSettingsTime(backup.createdAt),
      if (backup.reason != AutomaticBackupReason.scheduled) backup.reason.label,
      _size(backup.sizeBytes),
    ].join('  ·  ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Expanded(child: Text(details)),
        TextButton(onPressed: onRestore, child: const Text('Restore')),
      ]),
    );
  }

  static String _size(int bytes) {
    if (bytes >= 1 << 20) return '${(bytes / (1 << 20)).toStringAsFixed(1)} MB';
    return '${(bytes / 1024).ceil()} KB';
  }
}
