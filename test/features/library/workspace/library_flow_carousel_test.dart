import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/library_flow_carousel.dart';
import 'package:collectarr_app/features/library/workspace/library_browser_node.dart';
import 'package:collectarr_app/features/library/workspace/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('flow carousel navigates between items with arrow controls',
      (tester) async {
    String? activatedId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 760,
            child: LibraryFlowCarousel(
              items: [
                _item('movie-1', 'Arrival', year: 2016),
                _item('movie-2', 'Blade Runner 2049', year: 2017),
                _item('movie-3', 'Dune', year: 2021),
              ],
              selectedId: 'movie-1',
              selectedAnchorId: 'movie-1',
              selectedIds: const {},
              accent: const Color(0xFF7BCFA6),
              emptyBuilder: (_) => const Text('No items'),
              onApplySelection: (_, __) {},
              onActivateItem: (id) => activatedId = id,
              onToggleSelectionItem: (_) {},
              onOpenItem: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byKey(const ValueKey('flow-carousel-footer-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('flow-carousel-backdrop-movie-1')), findsOneWidget);
    expect(find.text('Arrival'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('flow-carousel-next')));
    await tester.pumpAndSettle();

    expect(activatedId, 'movie-2');
    expect(find.text('Blade Runner 2049'), findsWidgets);
    expect(find.byKey(const ValueKey('flow-carousel-backdrop-movie-2')), findsOneWidget);
  });

  testWidgets('flow carousel navigates with keyboard arrows', (tester) async {
    String? activatedId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 760,
            child: LibraryFlowCarousel(
              items: [
                _item('movie-1', 'Arrival', year: 2016),
                _item('movie-2', 'Blade Runner 2049', year: 2017),
                _item('movie-3', 'Dune', year: 2021),
              ],
              selectedId: 'movie-1',
              selectedAnchorId: 'movie-1',
              selectedIds: const {},
              accent: const Color(0xFF7BCFA6),
              emptyBuilder: (_) => const Text('No items'),
              onApplySelection: (_, __) {},
              onActivateItem: (id) => activatedId = id,
              onToggleSelectionItem: (_) {},
              onOpenItem: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    expect(activatedId, 'movie-2');
    expect(find.byKey(const ValueKey('flow-carousel-backdrop-movie-2')), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();

    expect(activatedId, 'movie-1');
    expect(find.byKey(const ValueKey('flow-carousel-backdrop-movie-1')), findsOneWidget);
  });
}

LibraryProjectionItem _item(String id, String title, {int? year}) {
  final entry = LibraryWorkspaceEntry(
    id: id,
    mediaType: 'movie',
    title: title,
    releaseYear: year,
    updatedAt: DateTime.utc(2026, 1, 1),
  );
  return LibraryProjectionItem(
    source: ShelfEntry(
      itemId: id,
      catalogItem: null,
      ownedItem: null,
      wishlistItem: null,
      trackingEntry: null,
    ),
    entry: entry,
    node: LibraryBrowserNode(
      id: id,
      scope: LibraryBrowserScope.title,
      entry: entry,
      titleItemId: id,
    ),
  );
}