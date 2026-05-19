import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/comics/inspector/comics_inspector.dart';
import 'package:collectarr_app/features/library/library_item_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('comic inspector renders empty selection state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ComicInspector(
              item: null,
              libraryState: LibraryItemState(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('No comic selected'), findsOneWidget);
  });

  test('comic inspector exposes shared condition presets', () {
    expect(ComicInspector.conditions, contains('Near Mint'));
    expect(ComicInspector.grades, contains('9.8'));
  });

  testWidgets('personal details editor rejects invalid price input',
      (tester) async {
    final ownedItem = OwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      condition: 'Near Mint',
      grade: 'Ungraded',
      pricePaidCents: 399,
      currency: 'USD',
      updatedAt: DateTime.utc(2026, 5, 13),
    );
    final mutations = _MutationCalls();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionMutationsProvider.overrideWith(
            (ref) => _RecordingCollectionMutations(ref, mutations),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 900,
              child: ComicInspector(
                item: const CatalogItem(
                  id: 'comic-1',
                  kind: 'comic',
                  title: 'Superman, Vol. 4',
                  itemNumber: '8A',
                ),
                libraryState: LibraryItemState(ownedItem: ownedItem),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Price paid'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Price paid'),
      'not-a-price',
    );
    await tester.scrollUntilVisible(
      find.text('Save personal details'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save personal details'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid price, for example 3.99'), findsOneWidget);
    expect(mutations.updateCalls, 0);
  });
}

class _RecordingCollectionMutations extends CollectionMutations {
  _RecordingCollectionMutations(super.ref, this.calls);

  final _MutationCalls calls;

  @override
  Future<void> updateItem(
    OwnedItem item, {
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int? quantity,
    String? storageBox,
    int? indexNumber,
    int? coverPriceCents,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    bool? keyComic,
    String? keyReason,
    int? rating,
    String? readStatus,
    String? tags,
    DateTime? soldAt,
    int? sellPriceCents,
    String? soldTo,
    bool notify = true,
  }) async {
    calls.updateCalls++;
  }
}

class _MutationCalls {
  int updateCalls = 0;
}
