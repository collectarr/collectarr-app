import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/library/generic/filters.dart';
import 'package:collectarr_app/features/library/generic/smart_lists_dialog.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('native smart list uses list and detail pages with shared save',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    SmartListLoadResult? loaded;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
            builder: (context) => TextButton(
                  onPressed: () async => loaded = await showSmartListsDialog(
                    context: context,
                    db: db,
                    mediaKind: 'comic',
                    currentFilter: const LibraryFilterSelection(),
                    currentTarget: SmartListCriteriaTarget.catalog,
                  ),
                  child: const Text('Open smart lists'),
                )),
      ),
    ));
    await tester.tap(find.text('Open smart lists'));
    await tester.pumpAndSettle();
    expect(find.byType(MobilePage), findsOneWidget);
    expect(find.text('Smart Lists'), findsOneWidget);
    await tester.tap(find.byTooltip('Save current view as smart list'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Unread QA');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.text('Smart List kinds'), findsOneWidget);
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unread QA').first);
    await tester.pumpAndSettle();
    expect(find.text('Saved view details'), findsOneWidget);
    await tester.tap(find.text('Load'));
    await tester.pumpAndSettle();
    expect(loaded, isNotNull);
    expect(loaded!.target, SmartListCriteriaTarget.catalog);
    await tester.pumpWidget(const SizedBox.shrink());
  }, variant: TargetPlatformVariant({TargetPlatform.android}));
}
