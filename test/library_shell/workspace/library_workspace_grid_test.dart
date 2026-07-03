import 'package:collectarr_app/features/library/workspace/layout/library_workspace_grid.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';

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

  testWidgets('workspace grid keeps uniform tile size while resizing width',
      (tester) async {
    final width = ValueNotifier<double>(500);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<double>(
          valueListenable: width,
          builder: (context, value, _) => SizedBox(
            width: value,
            height: 260,
            child: LibraryWorkspaceGrid<String>(
              items: const ['one', 'two', 'three', 'four'],
              maxCrossAxisExtent: 120,
              mainAxisExtent: 160,
              emptyBuilder: (_) => const Text('No items'),
              itemBuilder: (_, item) => SizedBox.expand(
                key: ValueKey('tile-$item'),
                child: Text(item),
              ),
            ),
          ),
        ),
      ),
    );

    final firstBefore = tester.getSize(find.byKey(const ValueKey('tile-one')));
    width.value = 495;
    await tester.pump();
    final firstAfter = tester.getSize(find.byKey(const ValueKey('tile-one')));

    expect(firstBefore.width, closeTo(120, 0.001));
    expect(firstAfter.width, closeTo(firstBefore.width, 0.001));
    expect(firstAfter.height, closeTo(firstBefore.height, 0.001));
  });

  testWidgets('workspace grid keeps first tile aligned to left shelf edge',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 560,
          height: 260,
          child: LibraryWorkspaceGrid<String>(
            items: const ['one', 'two', 'three'],
            maxCrossAxisExtent: 220,
            mainAxisExtent: 160,
            emptyBuilder: (_) => const Text('No items'),
            itemBuilder: (_, item) => SizedBox.expand(
              key: ValueKey('left-$item'),
              child: Text(item),
            ),
          ),
        ),
      ),
    );

    final gridLeft = tester.getTopLeft(find.byType(GridView)).dx;
    final firstLeft =
        tester.getTopLeft(find.byKey(const ValueKey('left-one'))).dx;
    expect(firstLeft, closeTo(gridLeft + 10, 0.001));
  });

  testWidgets('workspace grid keeps configured spacing between columns',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 260,
            child: LibraryWorkspaceGrid<String>(
              items: const ['one', 'two', 'three'],
              maxCrossAxisExtent: 120,
              mainAxisExtent: 160,
              crossAxisSpacing: 10,
              emptyBuilder: (_) => const Text('No items'),
              itemBuilder: (_, item) => SizedBox.expand(
                key: ValueKey('gap-$item'),
                child: Text(item),
              ),
            ),
          ),
        ),
      ),
    );

    final first = tester.getRect(find.byKey(const ValueKey('gap-one')));
    final second = tester.getRect(find.byKey(const ValueKey('gap-two')));
    expect(second.left - first.right, closeTo(10, 0.001));
  });

  testWidgets(
      'workspace grid shrinks column count before impossible compression',
      (tester) async {
    final width = ValueNotifier<double>(260);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<double>(
          valueListenable: width,
          builder: (context, value, _) => Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: value,
              height: 360,
              child: LibraryWorkspaceGrid<String>(
                items: const ['one', 'two'],
                maxCrossAxisExtent: 120,
                mainAxisExtent: 160,
                crossAxisSpacing: 10,
                emptyBuilder: (_) => const Text('No items'),
                itemBuilder: (_, item) => SizedBox.expand(
                  key: ValueKey('shrink-$item'),
                  child: Text(item),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    width.value = 200;
    await tester.pump();

    final first = tester.getRect(find.byKey(const ValueKey('shrink-one')));
    final second = tester.getRect(find.byKey(const ValueKey('shrink-two')));
    expect(first.width, closeTo(120, 0.001));
    expect(second.left, closeTo(first.left, 0.001));
  });

  testWidgets('workspace grid keeps child taps when selection is disabled', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 320,
          height: 220,
          child: LibraryWorkspaceGrid<String>(
            items: const ['Saga'],
            maxCrossAxisExtent: 120,
            mainAxisExtent: 160,
            itemIdOf: (item) => item,
            onSelectionChanged: (_) {},
            emptyBuilder: (_) => const Text('No items'),
            itemBuilder: (_, item) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => tapped = true,
              child: Text(item),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Saga'));
    await tester.pump();

    expect(tapped, isTrue);
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
            selectionEnabled: true,
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
            selectionEnabled: true,
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

  testWidgets('workspace grid ignores secondary-button drag selection',
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
            selectionEnabled: true,
            selectedIds: selected,
            itemIdOf: (item) => item,
            onSelectionChanged: (value) => selected = value,
            emptyBuilder: (_) => const Text('No items'),
            itemBuilder: (_, item) => Text(item),
          ),
        ),
      ),
    );

    final gridTopLeft = tester.getTopLeft(find.byType(GridView));
    final gesture = await tester.startGesture(
      gridTopLeft + const Offset(16, 16),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await gesture.moveTo(gridTopLeft + const Offset(225, 95));
    await gesture.up();
    await tester.pump();

    expect(selected, {'four'});
  });

  testWidgets(
      'workspace grid lays out inside sliver adapters when shrink-wrapped',
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
                  selectionEnabled: true,
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
