import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('edit scaffold footer shows navigation and action buttons', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _EditScaffoldHarness()));

    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
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
    await gesture.moveTo(tester.getCenter(mainLabel));
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
}

class _EditScaffoldHarness extends StatefulWidget {
  const _EditScaffoldHarness({this.contentHeight = 80});

  final double contentHeight;

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
