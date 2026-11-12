import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:collectarr_app/features/library/workspace/chrome/menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Favorites rules reach both edges and leave the longer line on the right',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Align(
      alignment: Alignment.topLeft,
      child:
          SizedBox(width: 260, child: LibraryToolbarMenuSection('Favorites')),
    ))));
    final section = tester.getRect(find.byType(LibraryToolbarMenuSection));
    final rules = find.byType(Divider);
    expect(tester.getRect(rules.first).left, section.left);
    expect(tester.getRect(rules.last).right, section.right);
    expect(tester.getSize(rules.last).width,
        greaterThan(tester.getSize(rules.first).width));
  });

  for (final palette in [kDefaultAppThemePalette, kLightAppThemePalette]) {
    testWidgets(
        'popup hover uses the shared solid color in ${palette.brightness.name}',
        (tester) async {
      const capture = Key('menu-capture');
      await tester.pumpWidget(RepaintBoundary(
          key: capture,
          child: MaterialApp(
            theme: buildAppShellTheme(palette: palette)
                .copyWith(hoverColor: Colors.pink),
            home: Scaffold(
                body: PopupMenuButton<String>(
              itemBuilder: (_) => const [
                LibraryToolbarMenuItem(
                    value: 'favorite', child: Text('Favorite'))
              ],
              child: const Text('Open'),
            )),
          )));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final item = find.byType(LibraryToolbarMenuItem<String>);
      final hover = libraryToolbarMenuHover(tester.element(item));
      final mouse =
          await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(item));
      await tester.pumpAndSettle();
      final boundary =
          tester.renderObject<RenderRepaintBoundary>(find.byKey(capture));
      final sample = tester.getTopLeft(item) + const Offset(4, 4);
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final pixels =
            await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final index = (sample.dy.floor() * image.width + sample.dx.floor()) * 4;
        expect(
            Color.fromARGB(pixels!.getUint8(index + 3), pixels.getUint8(index),
                pixels.getUint8(index + 1), pixels.getUint8(index + 2)),
            hover);
        image.dispose();
      });
      await mouse.removePointer();
    });
  }

  testWidgets('menu gear has its own hover and activates once', (tester) async {
    var activated = 0;
    await tester.pumpWidget(MaterialApp(
        theme: buildAppShellTheme(),
        home: Scaffold(
          body: LibraryToolbarMenuIconAction(
              icon: Icons.settings,
              label: 'Manage Favorites',
              onPressed: () => activated++),
        )));
    final action = find.byType(LibraryToolbarMenuIconAction);
    final ink = tester.widget<InkWell>(
        find.descendant(of: action, matching: find.byType(InkWell)));
    expect(
        ink.hoverColor, libraryToolbarMenuActionHover(tester.element(action)));
    expect(
        ink.hoverColor, isNot(libraryToolbarMenuHover(tester.element(action))));
    await tester.tap(action);
    expect(activated, 1);
  });

  testWidgets('menu row renders leading and trailing widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryWorkspaceMenuRow(
            label: 'Views',
            leading: Icon(Icons.grid_view_outlined),
            trailing: Icon(Icons.check),
          ),
        ),
      ),
    );

    expect(find.text('Views'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('menu section divider renders section label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryWorkspaceMenuSectionDivider(label: 'Folders'),
        ),
      ),
    );

    expect(find.text('Folders'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('tree header reflects highlight and expansion state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryWorkspaceMenuTreeHeader(
            label: 'Main',
            expanded: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Main'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });
}
