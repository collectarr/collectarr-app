import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_typography.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_layout_widgets.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('edit scaffold footer shows navigation and action buttons', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _EditScaffoldHarness()));

    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    final save =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));
    expect(save.style!.backgroundColor!.resolve({}), const Color(0xFF5EB1DE));
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    for (final label in ['Previous', 'Next']) {
      final button = find.widgetWithText(OutlinedButton, label);
      expect(tester.getSize(button), const Size(100, 32));
      expect(
          find.descendant(
              of: button,
              matching: find.byIcon(label == 'Previous'
                  ? AppIcons.chevronLeft
                  : AppIcons.chevronRight)),
          findsOneWidget);
      final style = tester.widget<OutlinedButton>(button).style!;
      final shared = dialogActionButtonStyle(tester.element(button));
      expect(style.backgroundColor!.resolve({WidgetState.disabled}),
          shared.backgroundColor!.resolve({WidgetState.disabled}));
      expect(style.backgroundColor!.resolve({WidgetState.hovered}),
          shared.backgroundColor!.resolve({WidgetState.hovered}));
    }

    expect(find.text('Cancel'), findsOneWidget);
    for (final label in ['Previous', 'Next', 'Cancel', 'Save']) {
      final style = DefaultTextStyle.of(tester.element(find.text(label))).style;
      expect(style.fontFamily, appFontFamily, reason: label);
      expect(style.fontSize, 14, reason: label);
      expect(style.fontWeight, FontWeight.w400, reason: label);
    }
  });

  testWidgets('edit dialog stays top-anchored as its content grows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: _EditScaffoldHarness(contentHeight: 100)),
      ),
    );
    final dialogSurface = find.byWidgetPredicate(
      (widget) => widget is Material && widget.type == MaterialType.card,
    );
    final initialTop = tester.getTopLeft(dialogSurface).dy;
    final initialBottom = tester.getBottomRight(dialogSurface).dy;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: _EditScaffoldHarness(contentHeight: 300)),
      ),
    );

    expect(tester.getTopLeft(dialogSurface).dy, closeTo(initialTop, 0.1));
    expect(
      tester.getBottomRight(dialogSurface).dy,
      greaterThan(initialBottom),
    );
  });

  testWidgets('reordering tabs keeps logical view order stable',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _EditScaffoldHarness()));

    expect(find.text('Main tab'), findsOneWidget);
    expect(find.text('Details tab'), findsNothing);

    final detailsLabel = find.text('Details');
    final mainLabel = find.text('Main');
    final gesture = await tester.startGesture(tester.getCenter(detailsLabel));
    await tester.pump(const Duration(milliseconds: 700));
    final start = tester.getCenter(detailsLabel);
    final target = tester.getCenter(mainLabel) + const Offset(20, 0);
    for (var step = 1; step <= 5; step++) {
      await gesture.moveTo(Offset.lerp(start, target, step / 5)!);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(detailsLabel).dx,
      lessThan(tester.getTopLeft(mainLabel).dx),
    );
    expect(find.text('Main tab'), findsOneWidget);

    await tester.tap(detailsLabel);
    await tester.pumpAndSettle();

    expect(find.text('Details tab'), findsOneWidget);
    expect(find.text('Main tab'), findsNothing);
  });

  testWidgets('an editor opened after a reorder starts in the saved order',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    const harness = _EditScaffoldHarness(tabOrderKey: 'scaffold_test_order');
    await tester.pumpWidget(const MaterialApp(home: harness));
    await tester.pumpAndSettle();

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Details')));
    await tester.pump(const Duration(milliseconds: 700));
    final start = tester.getCenter(find.text('Details'));
    final target = tester.getCenter(find.text('Main')) + const Offset(20, 0);
    for (var step = 1; step <= 5; step++) {
      await gesture.moveTo(Offset.lerp(start, target, step / 5)!);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    // Previous/Next builds a new editor: its very first frame must already
    // show the saved order, not the default one.
    await tester.pumpWidget(const MaterialApp(
        key: ValueKey('next'),
        home: _EditScaffoldHarness(tabOrderKey: 'scaffold_test_order')));
    expect(tester.getTopLeft(find.text('Details')).dx,
        lessThan(tester.getTopLeft(find.text('Main')).dx));
  });

  testWidgets('the first editor after a launch hides the default tab order',
      (tester) async {
    // A key no editor has loaded yet, as right after the app starts.
    SharedPreferences.setMockInitialValues({
      'scaffold_launch_order': ['1', '0'],
    });
    await tester.pumpWidget(const MaterialApp(
        home: _EditScaffoldHarness(tabOrderKey: 'scaffold_launch_order')));
    bool stripVisible() => tester
        .widget<Visibility>(find
            .ancestor(of: find.text('Main'), matching: find.byType(Visibility))
            .first)
        .visible;
    expect(stripVisible(), isFalse);

    await tester.pumpAndSettle();
    expect(stripVisible(), isTrue);
    expect(tester.getTopLeft(find.text('Details')).dx,
        lessThan(tester.getTopLeft(find.text('Main')).dx));
  });
}

class _EditScaffoldHarness extends StatefulWidget {
  const _EditScaffoldHarness({this.contentHeight = 80, this.tabOrderKey});

  final double contentHeight;
  final String? tabOrderKey;

  @override
  State<_EditScaffoldHarness> createState() => _EditScaffoldHarnessState();
}

class _EditScaffoldHarnessState extends State<_EditScaffoldHarness>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LibraryEditDialogScaffold(
          formKey: _formKey,
          accent: Colors.teal,
          icon: Icons.library_music,
          title: 'Edit album',
          badges: const [],
          tabController: _tabController,
          tabOrderKey: widget.tabOrderKey,
          tabs: const [
            EditTab(icon: Icons.info_outline, label: 'Main'),
            EditTab(icon: Icons.tune, label: 'Details'),
          ],
          views: [
            SizedBox(
              height: widget.contentHeight,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Main tab'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Details tab'),
            ),
          ],
          onClose: () {},
          onCancel: () {},
          onSave: () {},
        ),
      ),
    );
  }
}
