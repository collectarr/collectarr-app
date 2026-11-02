import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/generic/user_folders_dialog.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('native folders page creates a folder with the shared repository',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
            builder: (context) => TextButton(
                  onPressed: () => showUserFoldersDialog(
                      context: context, db: db, accent: Colors.teal),
                  child: const Text('Open folders'),
                )),
      ),
    ));
    await tester.tap(find.text('Open folders'));
    await tester.pumpAndSettle();
    expect(find.byType(MobilePage), findsOneWidget);
    expect(find.text('Folders'), findsOneWidget);
    expect(find.byTooltip('Create folder'), findsOneWidget);
    await tester.tap(find.byTooltip('Create folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mobile QA');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Mobile QA'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Open folders'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, variant: TargetPlatformVariant({TargetPlatform.android}));
}
