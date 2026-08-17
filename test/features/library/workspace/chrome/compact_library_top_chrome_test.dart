import 'package:collectarr_app/features/library/workspace/chrome/compact_library_top_chrome.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    TextEditingController? searchController,
    ValueChanged<String>? onSearchChanged,
    VoidCallback? onAdd,
    VoidCallback? onScanBarcode,
    VoidCallback? onOpenFilters,
    VoidCallback? onOpenViewOptions,
    VoidCallback? onSync,
    bool isSyncing = false,
    int syncPendingCount = 0,
  }) {
    return MaterialApp(
      home: Scaffold(
        appBar: CompactLibraryTopChrome(
          titleWidget: const Text('Comics (42)'),
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          onAdd: onAdd,
          onScanBarcode: onScanBarcode,
          onOpenFilters: onOpenFilters,
          onOpenViewOptions: onOpenViewOptions,
          onSync: onSync,
          isSyncing: isSyncing,
          syncPendingCount: syncPendingCount,
        ),
      ),
    );
  }

  testWidgets('renders standard top bar with action buttons and title',
      (tester) async {
    bool addPressed = false;
    bool scanPressed = false;
    bool filtersPressed = false;
    bool viewOptionsPressed = false;
    bool syncPressed = false;

    await tester.pumpWidget(
      LibraryAccentScope(
        kind: 'comic',
        accent: Colors.deepOrange,
        animationsEnabled: true,
        child: buildSubject(
          searchController: TextEditingController(),
          onAdd: () => addPressed = true,
          onScanBarcode: () => scanPressed = true,
          onOpenFilters: () => filtersPressed = true,
          onOpenViewOptions: () => viewOptionsPressed = true,
          onSync: () => syncPressed = true,
          syncPendingCount: 3,
        ),
      ),
    );

    expect(find.text('Comics (42)'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('compact_search_trigger')), findsOneWidget);
    expect(find.byKey(const ValueKey('compact_add_trigger')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('compact_barcode_trigger')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('compact_filters_trigger')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('compact_view_options_trigger')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('compact_sync_trigger')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // Test button taps
    await tester.tap(find.byKey(const ValueKey('compact_add_trigger')));
    expect(addPressed, isTrue);

    await tester.tap(find.byKey(const ValueKey('compact_barcode_trigger')));
    expect(scanPressed, isTrue);

    await tester.tap(find.byKey(const ValueKey('compact_filters_trigger')));
    expect(filtersPressed, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('compact_view_options_trigger')),
    );
    expect(viewOptionsPressed, isTrue);

    await tester.tap(find.byKey(const ValueKey('compact_sync_trigger')));
    expect(syncPressed, isTrue);
  });

  testWidgets('expands and collapses search mode smoothly', (tester) async {
    final searchController = TextEditingController();
    String? searchQuery;

    await tester.pumpWidget(
      LibraryAccentScope(
        kind: 'comic',
        accent: Colors.deepOrange,
        animationsEnabled: true,
        child: buildSubject(
          searchController: searchController,
          onSearchChanged: (val) => searchQuery = val,
        ),
      ),
    );

    expect(
        find.byKey(const ValueKey('compact_search_text_field')), findsNothing);

    // Tap search button to expand
    await tester.tap(find.byKey(const ValueKey('compact_search_trigger')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('compact_search_text_field')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('compact_search_back')), findsOneWidget);

    // Enter search text
    await tester.enterText(
      find.byKey(const ValueKey('compact_search_text_field')),
      'Batman',
    );
    expect(searchQuery, 'Batman');

    // Tap back button to collapse
    await tester.tap(find.byKey(const ValueKey('compact_search_back')));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('compact_search_text_field')), findsNothing);
    expect(searchQuery, '');
    expect(searchController.text, '');
  });
}
