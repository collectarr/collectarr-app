import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/detail/adaptive_item_detail_presentation.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  testWidgets(
      'showAdaptiveItemDetail pushes full-screen page on compact screen',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.comic)!;

    final source = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Batman: Year One',
      ),
    );

    final item = LibraryProjectionItem.fromShelf(source, type);

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showAdaptiveItemDetail(
                      context: context,
                      type: type,
                      item: item,
                      ownedItem: null,
                      accent: Colors.deepOrange,
                      onAddOwned: () {},
                      onRemoveOwned: () {},
                      onAddWishlist: () {},
                      onRemoveWishlist: () {},
                      onEdit: (_) {},
                    );
                  },
                  child: const Text('Open Detail'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Detail'));
    await tester.pumpAndSettle();

    expect(find.byType(LibraryDetailPage), findsOneWidget);
    expect(find.text('Batman: Year One'), findsWidgets);
  });
}
