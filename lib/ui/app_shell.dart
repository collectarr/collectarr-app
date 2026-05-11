import 'package:collectarr_app/features/collection/collection_page.dart';
import 'package:collectarr_app/features/comics/comics_page.dart';
import 'package:collectarr_app/features/games/games_page.dart';
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
    ComicsPage(),
    CollectionPage(),
    GamesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncControllerProvider);
    return Scaffold(
      body: pages[index],
      floatingActionButton: FloatingActionButton.small(
        tooltip: sync.isOffline ? 'Sync unavailable' : 'Sync personal data',
        onPressed: sync.isSyncing
            ? null
            : () => ref.read(syncControllerProvider.notifier).syncNow(),
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
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Comics'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Shelf'),
          NavigationDestination(
              icon: Icon(Icons.sports_esports), label: 'Games'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
