import 'package:collectarr_app/features/library/workspace/library_workspace_grid.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  testWidgets('workspace grid renders empty state when there are no items',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LibraryWorkspaceGrid<String>(
          items: const [],
          maxCrossAxisExtent: 120,
          mainAxisExtent: 160,
          emptyBuilder: (_) => const Text('No items'),
          itemBuilder: (_, item) => Text(item),
        ),
      ),
    );

    expect(find.text('No items'), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('workspace grid renders item tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 320,
          height: 220,
          child: LibraryWorkspaceGrid<String>(
            items: const ['Spider-Man', 'Batman'],
            maxCrossAxisExtent: 120,
            mainAxisExtent: 160,
            emptyBuilder: (_) => const Text('No items'),
            itemBuilder: (_, item) => Text(item),
          ),
        ),
      ),
    );

    expect(find.text('Spider-Man'), findsOneWidget);
    expect(find.text('Batman'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('workspace grid supports drag box selection without modifiers',
      (tester) async {
    Set<String> selected = const {};

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 250,
          height: 240,
          child: LibraryWorkspaceGrid<String>(
            items: const ['one', 'two', 'three', 'four'],
            maxCrossAxisExtent: 120,
            mainAxisExtent: 100,
            itemIdOf: (item) => item,
            onSelectionChanged: (value) => selected = value,
            emptyBuilder: (_) => const Text('No items'),
            itemBuilder: (_, item) => Text(item),
          ),
        ),
      ),
    );

    final gridTopLeft = tester.getTopLeft(find.byType(GridView));
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(gesture.removePointer);
  await gesture.addPointer(location: gridTopLeft + const Offset(16, 16));
  await tester.pump();
  await gesture.down(gridTopLeft + const Offset(16, 16));
    await gesture.moveTo(gridTopLeft + const Offset(225, 95));
    await gesture.up();
    await tester.pump();

    expect(selected, {'one', 'two'});
  });

  testWidgets('workspace grid adds to existing selection when ctrl-dragging',
      (tester) async {
    Set<String> selected = {'four'};

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 250,
          height: 240,
          child: LibraryWorkspaceGrid<String>(
            items: const ['one', 'two', 'three', 'four'],
            maxCrossAxisExtent: 120,
            mainAxisExtent: 100,
            selectedIds: selected,
            itemIdOf: (item) => item,
            onSelectionChanged: (value) => selected = value,
            emptyBuilder: (_) => const Text('No items'),
            itemBuilder: (_, item) => Text(item),
          ),
        ),
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    addTearDown(() => tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft));

    final gridTopLeft = tester.getTopLeft(find.byType(GridView));
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(gesture.removePointer);
  await gesture.addPointer(location: gridTopLeft + const Offset(16, 16));
  await tester.pump();
  await gesture.down(gridTopLeft + const Offset(16, 16));
    await gesture.moveTo(gridTopLeft + const Offset(225, 95));
    await gesture.up();
    await tester.pump();

    expect(selected, {'one', 'two', 'four'});
  });

  testWidgets('workspace grid lays out inside sliver adapters when shrink-wrapped',
      (tester) async {
    Set<String> selected = const {};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: LibraryWorkspaceGrid<String>(
                  items: const ['one', 'two', 'three', 'four'],
                  maxCrossAxisExtent: 120,
                  mainAxisExtent: 100,
                  itemIdOf: (item) => item,
                  onSelectionChanged: (value) => selected = value,
                  shrinkWrap: true,
                  scrollable: false,
                  emptyBuilder: (_) => const Text('No items'),
                  itemBuilder: (_, item) => Text(item),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('one'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(selected, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
