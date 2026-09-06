import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every registered catalog kind owns a collection CSV projection', () {
    final registeredKinds = collectarrKindModules
        .map((module) => module.kind)
        .where((kind) => !kind.isUnknown)
        .toSet();
    final projectedKinds = libraryCollectionCsvProjections
        .map((projection) => projection.kind)
        .toSet();

    expect(registeredKinds, hasLength(9));
    expect(projectedKinds, registeredKinds);
    expect(
      libraryCollectionCsvProjections,
      hasLength(registeredKinds.length),
    );

    for (final kind in registeredKinds) {
      final projection = libraryCollectionCsvProjectionForKind(kind);
      expect(projection, isNotNull, reason: kind.apiValue);
      expect(
        projection!.clzFriendlyHeader,
        hasLength(38),
        reason: kind.apiValue,
      );
      expect(projection.columnAliases, isNotEmpty, reason: kind.apiValue);
      expect(
        projection.importCatalogCells(
          header: const ['Media Type'],
          values: [kind.apiValue],
        ),
        hasLength(11),
        reason: kind.apiValue,
      );
      expect(
        projection.importOwnedCells(
          header: const ['Media Type'],
          values: [kind.apiValue],
        ),
        hasLength(9),
        reason: kind.apiValue,
      );

      final item = testCatalogItem(
        id: 'projection-${kind.apiValue}',
        kind: kind.apiValue,
        title: 'Contract item',
        itemNumber: '7',
        variant: 'Primary',
        publisher: 'Contract publisher',
        releaseYear: 2024,
        barcode: '0123456789',
      );
      expect(
        projection.catalogDisplayTitle(item),
        contains('Contract item'),
        reason: kind.apiValue,
      );
      expect(
        projection.catalogDisplaySubtitle(item),
        contains('2024'),
        reason: kind.apiValue,
      );
      expect(
        projection.catalogMatchesBarcode(item, '0123456789'),
        isTrue,
        reason: kind.apiValue,
      );
    }
  });
}
