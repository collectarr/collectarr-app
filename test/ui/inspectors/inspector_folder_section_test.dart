import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/inspector/inspector_folder_section.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  testWidgets('folder section keeps current folders when picker is cancelled', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.userFoldersCache).insert(
          UserFoldersCacheCompanion.insert(
            id: 'folder-1',
            name: 'Favorites',
            sortOrder: const Value(1),
          ),
        );
    await db.into(db.userFolderItemsCache).insert(
          UserFolderItemsCacheCompanion.insert(
            folderId: 'folder-1',
            ownedItemId: 'owned-1',
            sortOrder: const Value(1),
          ),
        );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorFolderSection(
            ownedItemId: 'owned-1',
            db: db,
            accent: Colors.orange,
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Favorites'), findsOneWidget);

    await tester.tap(find.byTooltip('Add to folder'));
    await pumpUntilSettled(tester);

    expect(find.text('Add to Folder'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await pumpUntilSettled(tester);

    final folderItems = await db.select(db.userFolderItemsCache).get();
    expect(folderItems, hasLength(1));
    expect(folderItems.single.folderId, 'folder-1');
    expect(folderItems.single.ownedItemId, 'owned-1');
    expect(find.text('Favorites'), findsOneWidget);
  });
}