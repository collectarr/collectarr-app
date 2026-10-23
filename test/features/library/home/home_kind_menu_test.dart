import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_kind_menu.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

CatalogMediaType _type(String kind, String plural) =>
    CatalogMediaType(kind: kind, singularLabel: plural, pluralLabel: plural);

void main() {
  for (final width in [390.0, 1200.0]) {
    testWidgets('switcher fills right edge and points to its icon at $width px',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
        appBar: AppBar(actions: [
          MediaLibraryKindMenu(
            types: [_type('game', 'Games'), _type('music', 'Albums')],
            registry: defaultLibraryKindRegistry,
            onSelected: (_) {},
          ),
          const SizedBox(width: 84),
        ]),
      )));
      await tester.tap(find.byTooltip('Switch library'));
      await tester.pumpAndSettle();
      final anchor =
          tester.getRect(find.byKey(const Key('nav.library-kind-picker')));
      final panel = find.byWidgetPredicate((w) =>
          w is Material && w.elevation == 6 && w.shape is OutlinedBorder);
      expect(panel, findsOneWidget);
      final bounds = tester.getRect(panel);
      expect(bounds.right, closeTo(width, .01));
      expect(bounds.center.dx, closeTo(anchor.center.dx, .01));
      final shape = tester.widget<Material>(panel).shape!;
      final outline = shape.getOuterPath(Offset.zero & bounds.size);
      final tip = Offset(anchor.center.dx - bounds.left, -7.5);
      expect(outline.contains(tip), isTrue);
      expect(outline.contains(tip + const Offset(2, 0)), isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Games'), findsNothing);
      await tester.tap(find.byTooltip('Switch library'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 300));
      await tester.pumpAndSettle();
      expect(find.text('Games'), findsNothing);
    });
  }

  testWidgets('the library menu lists a collection family once',
      (tester) async {
    CatalogMediaType? selected;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MediaLibraryKindMenu(
          types: [
            _type('game', 'Games'),
            _type('game_hardware', 'Hardware'),
            _type('game_toy', 'Toys'),
            _type('music', 'Albums'),
          ],
          registry: defaultLibraryKindRegistry,
          onSelected: (type) => selected = type,
        ),
      ),
    ));

    await tester.tap(find.byTooltip('Switch library'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('library-kind-picker-item-game')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('library-kind-picker-item-game_hardware')),
        findsNothing);
    expect(find.byKey(const ValueKey('library-kind-picker-item-game_toy')),
        findsNothing);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);

    await tester.tap(find.text('Games'));
    await tester.pumpAndSettle();
    expect(selected?.kind, 'game');
  });
}
