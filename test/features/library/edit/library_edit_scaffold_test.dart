import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('edit scaffold footer shows context fields and tab navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _EditScaffoldHarness()));

    expect(find.text('Footer context'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);

    final previousBefore = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Previous'),
    );
    final nextBefore = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Next'),
    );
    expect(previousBefore.onPressed, isNull);
    expect(nextBefore.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);

    final previousAfter = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Previous'),
    );
    final nextAfter = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Next'),
    );
    expect(previousAfter.onPressed, isNotNull);
    expect(nextAfter.onPressed, isNull);
  });
}

class _EditScaffoldHarness extends StatefulWidget {
  const _EditScaffoldHarness();

  @override
  State<_EditScaffoldHarness> createState() => _EditScaffoldHarnessState();
}

class _EditScaffoldHarnessState extends State<_EditScaffoldHarness>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController = TabController(length: 2, vsync: this);

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
          views: const [
            SizedBox.expand(child: Text('Main tab')),
            SizedBox.expand(child: Text('Details tab')),
          ],
          footerLabel: 'Footer context',
          footerFields: const [
            FooterReadonlyField(label: 'State', value: 'Draft', width: 96),
          ],
          onPrevious: () => _tabController.animateTo(_tabController.index - 1),
          onNext: () => _tabController.animateTo(_tabController.index + 1),
          onCancel: () {},
          onSave: () {},
        ),
      ),
    );
  }
}