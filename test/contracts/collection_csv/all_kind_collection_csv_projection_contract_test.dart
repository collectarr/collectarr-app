import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
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
      final importedOwnedCells = projection.importOwnedCells(
        header: const ['Media Type'],
        values: [kind.apiValue],
      );
      expect(importedOwnedCells, isNotNull, reason: kind.apiValue);
      expect(
        importedOwnedCells!.length,
        allOf(greaterThanOrEqualTo(9), lessThanOrEqualTo(10)),
        reason: kind.apiValue,
      );
      final importedOwnedPayload = projection.ownedItemImportPayload(
        LibraryCollectionCsvOwnedImport(
          id: 'owned-${kind.apiValue}',
          catalogRef: CatalogEntityRef(
            kind: kind,
            entityType: const CatalogEntityTypeId('work'),
            id: 'catalog-${kind.apiValue}',
          ),
          now: DateTime.utc(2026, 1, 1),
          kindOwnedCells: importedOwnedCells,
        ),
      );
      expect(importedOwnedPayload, isNotEmpty, reason: kind.apiValue);

      expect(
        projection.importDisplayTitle([
          'import-${kind.apiValue}',
          kind.apiValue,
          'Imported item',
          '7',
          'Primary',
          '',
          '',
          '',
          'Contract publisher',
          '2024-01-01',
          '0123456789',
        ]),
        'Imported item #7',
        reason: kind.apiValue,
      );
      expect(
        projection.importDisplaySubtitle([
          'import-${kind.apiValue}',
          kind.apiValue,
          'Imported item',
          '7',
          'Primary',
          '',
          '',
          '',
          'Contract publisher',
          '2024-01-01',
          '0123456789',
        ]),
        contains('Contract publisher'),
        reason: kind.apiValue,
      );
      final imported = projection.catalogItemFromImportCells([
        'import-${kind.apiValue}',
        kind.apiValue,
        'Imported item',
        '7',
        'Primary',
        '',
        '',
        '',
        'Contract publisher',
        '2024-01-01',
        '0123456789',
      ]);
      expect(imported, isNotNull, reason: kind.apiValue);
      expect(imported!.id, 'import-${kind.apiValue}', reason: kind.apiValue);
      expect(imported.kind, kind, reason: kind.apiValue);
      expect(imported.title, 'Imported item', reason: kind.apiValue);
    }
  });
}
