import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'dart:async';
import 'dart:convert';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_codec.dart';
import 'package:collectarr_app/features/collection/csv/import_export/import_export_wizard.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/settings/database_backup.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup_controller.dart';
import 'package:collectarr_app/features/settings/settings_backups_panel.dart';
import 'package:collectarr_app/features/settings/local_database_maintenance.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/settings/settings_layout.dart';

/// Settings > Data: import/export, backups and clearing the local database.
class SettingsDataSection extends ConsumerStatefulWidget {
  const SettingsDataSection({super.key});

  @override
  ConsumerState<SettingsDataSection> createState() =>
      _SettingsDataSectionState();
}

class _SettingsDataSectionState extends ConsumerState<SettingsDataSection> {
  @override
  Widget build(BuildContext context) => _buildDataSection();

  Widget _buildDataSection() {
    return SettingsTabBody(
      children: [
        SettingsPanel(
          icon: Icons.backup_outlined,
          title: 'Local backup',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Import or export your local collection as Collectarr CSV, CLZ-friendly CSV, or ComicInfo.xml. Personal fields stored on this device stay in the exported data.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => _showImportExportWizard(initialIndex: 1),
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('Import collection'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _showImportExportWizard(initialIndex: 0),
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Export collection'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copyBackup(clzFriendly: false),
                    icon: const Icon(Icons.copy_all),
                    label: const Text('Copy Collectarr export'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copyBackup(clzFriendly: true),
                    icon: const Icon(Icons.table_view),
                    label: const Text('Copy CLZ-friendly export'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _copySyncBackupGuide,
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Copy sync backup guide'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SettingsAutomaticBackupsPanel(),
        SettingsPanel(
          icon: Icons.save_outlined,
          title: 'Database backup & restore',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create a full JSON backup of your local database, or restore from a previous backup. '
                'This includes all collection, wishlist, tracking, custom fields, locations, smart lists, and queue data.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _backupDatabase,
                    icon: const Icon(Icons.save_alt_outlined),
                    label: const Text('Backup to JSON'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _restoreDatabase,
                    icon: const Icon(Icons.restore_outlined),
                    label: const Text('Restore from JSON'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SettingsPanel(
          icon: Icons.delete_forever_outlined,
          title: 'Clear database',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Permanently delete ALL local data including collection, wishlist, tracking, custom fields, and settings. '
                'This cannot be undone.',
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: _clearDatabase,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Clear entire database'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _copyBackup({required bool clzFriendly}) async {
    final state = await ref.read(shelfProvider.future);
    final db = ref.read(localDatabaseProvider);
    final cfRepo = CustomFieldRepository(db);
    final cfDefs = await cfRepo.listDefinitions();
    final cfValues = await cfRepo.listAllValues();
    final entryRecordsByRef = await LibraryEntryStore(db).findByRefs(
      state.entries
          .map((entry) => entry.libraryEntryRef)
          .whereType<LibraryEntryRef>(),
    );
    final csv = CollectionCsvCodec(profiles: collectionCsvKindProfiles);
    final data = clzFriendly
        ? csv.exportClzFriendlyShelf(
            state.entries,
            customFieldDefinitions: cfDefs,
            customFieldValuesByItem: cfValues,
            entryRecordsByRef: entryRecordsByRef,
          )
        : csv.exportShelf(
            state.entries,
            customFieldDefinitions: cfDefs,
            customFieldValuesByItem: cfValues,
            entryRecordsByRef: entryRecordsByRef,
          );
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) {
      return;
    }
    showSettingsToast(
      clzFriendly
          ? 'CLZ-friendly CSV backup copied'
          : 'Collectarr CSV backup copied',
      tone: AppToastTone.success,
    );
  }

  Future<void> _showImportExportWizard({required int initialIndex}) async {
    final state = await ref.read(shelfProvider.future);
    final db = ref.read(localDatabaseProvider);
    final cfRepo = CustomFieldRepository(db);
    final cfDefs = await cfRepo.listDefinitions();
    final cfValues = await cfRepo.listAllValues();
    final entryRecordsByRef = await LibraryEntryStore(db).findByRefs(
      state.entries
          .map((entry) => entry.libraryEntryRef)
          .whereType<LibraryEntryRef>(),
    );
    if (!mounted) {
      return;
    }
    final imported = await showAppDialog<int>(
      context: context,
      builder: (context) => ImportExportWizardDialog(
        entries: state.entries,
        profiles: collectionCsvKindProfiles,
        initialIndex: initialIndex,
        customFieldDefinitions: cfDefs,
        customFieldValuesByItem: cfValues,
        entryRecordsByRef: entryRecordsByRef,
      ),
    );
    if (imported != null && mounted) {
      showSettingsToast(
        'Imported $imported rows into your collection',
        tone: AppToastTone.success,
      );
    }
  }

  Future<void> _copySyncBackupGuide() async {
    final guide = [
      'Sync backup',
      '1. Stop collectarr-sync.',
      '2. Copy collectarr-sync.db plus -wal/-shm sidecars if present.',
      '3. Store the backup with the SYNC_API_KEY used by your devices.',
      '4. Restore while collectarr-sync is stopped, then run Check sync service.',
      '5. If conflicts appear after restore, choose Keep service or Keep local in Settings.',
      '',
      'Docker:',
      'docker compose --profile sync stop sync',
      'docker compose --profile sync cp sync:/data ./collectarr-sync-data',
      'Compress-Archive -Path .\\collectarr-sync-data\\* -DestinationPath .\\collectarr-sync-data.zip -Force',
      '',
      'Restore:',
      'docker compose --profile sync stop sync',
      'docker compose --profile sync cp ./collectarr-sync-data/. sync:/data',
      'docker compose --profile sync start sync',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: guide));
    if (!mounted) {
      return;
    }
    showSettingsToast('Sync backup guide copied', tone: AppToastTone.success);
  }

  Future<void> _backupDatabase() async {
    try {
      final db = ref.read(localDatabaseProvider);
      final backup = DatabaseBackup(db);
      final json = await backup.exportJson();
      final now = DateTime.now();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
          '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'collectarr_backup_$stamp.json';
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          const XTypeGroup(label: 'JSON', extensions: ['json']),
        ],
      );
      if (location == null) return;
      final file = XFile.fromData(
        utf8.encode(json),
        mimeType: 'application/json',
        name: fileName,
      );
      await file.saveTo(location.path);
      if (mounted) {
        showSettingsToast('Backup saved', tone: AppToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        showSettingsToast('Backup failed: ${describeSettingsError(e)}',
            tone: AppToastTone.error);
      }
    }
  }

  Future<void> _restoreDatabase() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(label: 'JSON', extensions: ['json']),
        ],
      );
      if (file == null) return;
      if (!mounted) return;
      final confirmed = await showAppDialog<bool>(
        context: context,
        builder: (ctx) => AccentAlertDialog(
          headerIcon: AppIcons.backupRestore,
          title: const Text('Restore database'),
          content: Text(
            'This will replace ALL local data with the backup contents. '
            '${_keptCopyNote('Current data will be lost.')} Pending sync '
            'changes contained in the backup will be kept and uploaded on the '
            'next sync. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      final content = await file.readAsString();
      final data = jsonDecode(content);
      if (data is! Map<String, dynamic>) {
        showSettingsToast('Invalid backup file', tone: AppToastTone.error);
        return;
      }
      await _backUpBefore(AutomaticBackupReason.beforeRestore);
      if (!mounted) return;
      await LocalDatabaseMaintenanceCoordinator(ref).restore(data);
      if (mounted) {
        showSettingsToast('Database restored', tone: AppToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        showSettingsToast('Restore failed: ${describeSettingsError(e)}',
            tone: AppToastTone.error);
      }
    }
  }

  /// Where Automatic backups exist, the data is copied there first.
  String _keptCopyNote(String withoutBackups) =>
      ref.read(automaticBackupProvider.notifier).isSupported
          ? 'A copy of the current data is kept in Automatic backups first.'
          : withoutBackups;

  /// Keeps a copy of the data a restore or clear is about to replace. If the
  /// copy fails, the error stops the operation before anything changes.
  Future<void> _backUpBefore(AutomaticBackupReason reason) async {
    final backups = ref.read(automaticBackupProvider.notifier);
    if (!backups.isSupported) return;
    try {
      await backups.backUp(reason: reason);
    } catch (error) {
      throw StateError('Could not back up the current data first, so '
          'nothing was changed: ${describeSettingsError(error)}');
    }
  }

  Future<void> _clearDatabase() async {
    final firstConfirm = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AccentAlertDialog(
        headerIcon: AppIcons.delete,
        title: const Text('Clear database'),
        content: Text(
          'This will delete ALL local data. '
          '${_keptCopyNote('This action cannot be undone.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (firstConfirm != true || !mounted) return;

    final secondConfirm = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AccentAlertDialog(
        headerIcon: AppIcons.delete,
        title: const Text('Are you absolutely sure?'),
        content: const Text(
          'All collection data, tracking history, custom fields, '
          'locations, smart lists, reading queues, and pending sync changes '
          'will be permanently erased. Remote sync data remains and will be '
          'pulled again the next time you sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Yes, delete everything'),
          ),
        ],
      ),
    );
    if (secondConfirm != true || !mounted) return;

    try {
      await _backUpBefore(AutomaticBackupReason.beforeClear);
      if (!mounted) return;
      await LocalDatabaseMaintenanceCoordinator(ref).clear();
      if (mounted) {
        showSettingsToast('Database cleared', tone: AppToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        showSettingsToast('Clear failed: ${describeSettingsError(e)}',
            tone: AppToastTone.error);
      }
    }
  }
}
