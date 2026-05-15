import 'package:collectarr_app/features/admin/admin_page.dart';
import 'package:collectarr_app/features/collection/collection_page.dart';
import 'package:collectarr_app/features/library/library_home_page.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int index = 0;

  static const pages = [
    LibraryHomePage(),
    CollectionPage(),
    AdminPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncControllerProvider);
    return Scaffold(
      body: pages[index],
      floatingActionButton: FloatingActionButton.small(
        tooltip: _syncTooltip(sync),
        onPressed: sync.isSyncing ? null : _syncNow,
        child: sync.isSyncing
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Badge(
                isLabelVisible: sync.pendingCount > 0,
                label: Text(sync.pendingCount.toString()),
                child: Icon(sync.isOffline ? Icons.cloud_off : Icons.sync),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.apps_outlined), label: 'Libraries'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Shelf'),
          NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined), label: 'Admin'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  Future<void> _syncNow() async {
    await ref.read(syncControllerProvider.notifier).syncNow();
    if (!mounted) {
      return;
    }
    final sync = ref.read(syncControllerProvider);
    final message = _syncResultMessage(sync);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _syncTooltip(SyncState sync) {
    if (sync.isOffline) {
      return sync.errorMessage ?? 'Sync unavailable';
    }
    if (sync.warningMessage != null) {
      return sync.warningMessage!;
    }
    final pending = sync.pendingCount == 0
        ? 'no pending changes'
        : '${sync.pendingCount} pending';
    final last = sync.lastSyncedAt == null
        ? 'never synced'
        : 'last sync ${_formatSyncTime(sync.lastSyncedAt!)}';
    return 'Sync personal data - $pending, $last';
  }

  String _syncResultMessage(SyncState sync) {
    if (sync.errorMessage != null) {
      return 'Personal sync unavailable: ${sync.errorMessage}';
    }
    return sync.warningMessage ?? 'Personal sync complete';
  }

  String _formatSyncTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:$minute';
  }
}
