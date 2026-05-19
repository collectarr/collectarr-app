import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/owned_comic_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('owned comic edit dialog returns edited personal fields',
      (tester) async {
    final item = CatalogItem(
      id: 'comic-1',
      kind: 'comic',
      title: 'Superman, Vol. 4',
      itemNumber: '8A',
      synopsis: 'Escape From Dinosaur Island',
      publisher: 'DC',
      releaseYear: 2016,
      barcode: '76194134192700811',
    );
    final ownedItem = OwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      condition: 'Near Mint',
      grade: '9.8',
      pricePaidCents: 1299,
      coverPriceCents: 399,
      currency: 'USD',
      quantity: 1,
      storageBox: 'Box 1',
      updatedAt: DateTime.utc(2026, 5, 11),
    );
    OwnedComicEditSelection? selection;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                selection = await showDialog<OwnedComicEditSelection>(
                  context: context,
                  builder: (context) => OwnedComicEditDialog(
                    item: item,
                    ownedItem: ownedItem,
                    conditions: const ['Near Mint', 'Fine'],
                    grades: const ['Ungraded', '9.8'],
                    cover: const ColoredBox(color: Colors.blue),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Edit - Superman, Vol. 4'), findsOneWidget);
    expect(find.text('Collection Status'), findsOneWidget);
    expect(find.text('1 / 7'), findsOneWidget);
    expect(find.text('Comic'), findsOneWidget);
    await tester.tap(find.text('Value'));
    await tester.pumpAndSettle();
    expect(find.text('Value by grade'), findsOneWidget);
    expect(find.text('Research integration placeholder'), findsNothing);
    expect(find.text('Paid: '), findsOneWidget);
    expect(find.text(r'$12.99'), findsOneWidget);
    expect(find.text('Cover: '), findsOneWidget);
    expect(find.text(r'$3.99'), findsOneWidget);
    expect(find.text('Barcode: '), findsOneWidget);
    expect(find.text('76194134192700811'), findsOneWidget);
    await tester.tap(find.text('Main'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 7'), findsOneWidget);
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Storage box'), 'Box 6');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(selection?.storageBox, 'Box 6');
    expect(selection?.condition, 'Near Mint');
    expect(selection?.grade, '9.8');
  });
}
