import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_manager_page.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('native pick list manager is a page and keeps list selection',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => ElevatedButton(
                    onPressed: () => showPickListManagerDialog(
                        context: context,
                        db: db,
                        registry: defaultPickListRegistry,
                        initialMediaKind: 'music'),
                    child: const Text('Open'))))));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(MobilePage), findsOneWidget);
    expect(find.text('Select a list...'), findsOneWidget);
    expect(find.text('Merge Mode'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(MobilePage), findsNothing);
  }, variant: TargetPlatformVariant({TargetPlatform.android}));
}
