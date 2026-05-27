import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('edit scaffold footer shows only Save button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _EditScaffoldHarness()));

    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    expect(find.text('Previous'), findsNothing);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
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
          onClose: () {},
          onSave: () {},
        ),
      ),
    );
  }
}
