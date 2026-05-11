import 'package:collectarr_app/features/collection/collection_page.dart';
import 'package:collectarr_app/features/comics/comics_page.dart';
import 'package:collectarr_app/features/games/games_page.dart';
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Comics'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Shelf'),
          NavigationDestination(
              icon: Icon(Icons.sports_esports), label: 'Games'),
        ],
      ),
    );
  }
}
