import 'package:collectarr_app/features/library/workspace/layout/compact_workspace_views.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestItem {
  const _TestItem(
      {required this.id, required this.title, required this.subtitle});
  final String id;
  final String title;
  final String subtitle;
}

void main() {
  final testItems = [
    const _TestItem(id: '1', title: 'Spider-Man #1', subtitle: 'Marvel Comics'),
    const _TestItem(id: '2', title: 'Batman #1', subtitle: 'DC Comics'),
  ];

  testWidgets(
      'CompactWorkspaceListView renders items and handles taps and selection',
      (tester) async {
    _TestItem? longPressedItem;
    _TestItem? selectedItem;
    bool? selectState;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryAccentScope(
            kind: 'comic',
            accent: Colors.deepOrange,
            animationsEnabled: true,
            child: CompactWorkspaceListView<_TestItem>(
              items: testItems,
              titleBuilder: (i) => i.title,
              subtitleBuilder: (i) => i.subtitle,
              idExtractor: (i) => i.id,
              onItemLongPress: (i) => longPressedItem = i,
              onItemSelect: (i, sel) {
                selectedItem = i;
                selectState = sel;
              },
              selectionMode: true,
              selectedIds: const {'1'},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Spider-Man #1'), findsOneWidget);
    expect(find.text('Batman #1'), findsOneWidget);
    expect(find.text('Marvel Comics'), findsOneWidget);
    expect(find.text('DC Comics'), findsOneWidget);

    // Tap first item in selection mode
    await tester.tap(find.text('Spider-Man #1'));
    await tester.pumpAndSettle();
    expect(selectedItem?.id, '1');
    expect(selectState, isFalse);

    // Long press second item
    await tester.longPress(find.text('Batman #1'));
    await tester.pumpAndSettle();
    expect(longPressedItem?.id, '2');
  });

  testWidgets(
      'CompactWorkspaceListView triggers onItemTap when not in selection mode',
      (tester) async {
    _TestItem? tappedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryAccentScope(
            kind: 'comic',
            accent: Colors.deepOrange,
            animationsEnabled: true,
            child: CompactWorkspaceListView<_TestItem>(
              items: testItems,
              titleBuilder: (i) => i.title,
              onItemTap: (i) => tappedItem = i,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Spider-Man #1'));
    await tester.pumpAndSettle();
    expect(tappedItem?.id, '1');
  });

  testWidgets('CompactWorkspaceGridView renders items in responsive grid',
      (tester) async {
    _TestItem? tappedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryAccentScope(
            kind: 'comic',
            accent: Colors.deepOrange,
            animationsEnabled: true,
            child: CompactWorkspaceGridView<_TestItem>(
              items: testItems,
              titleBuilder: (i) => i.title,
              subtitleBuilder: (i) => i.subtitle,
              idExtractor: (i) => i.id,
              onItemTap: (i) => tappedItem = i,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Spider-Man #1'), findsOneWidget);
    expect(find.text('Batman #1'), findsOneWidget);

    await tester.tap(find.text('Spider-Man #1'));
    await tester.pumpAndSettle();
    expect(tappedItem?.id, '1');
  });
}
