import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Universal TransferableField', () {
    test('reads and writes common OwnedItem fields without kind details', () {
      final item = OwnedItem(
        id: 'item-1',
        catalogRef: const CatalogEntityRef(
          id: 'work-1',
          kind: 'comic',
          entityType: CatalogEntityType.work,
        ),
        condition: 'Mint',
        grade: '9.8',
        personalNotes: 'First print run',
        pricePaidCents: 450,
        updatedAt: DateTime(2026, 1, 1),
      );

      final condField = TransferableField.universalBuiltIn
          .firstWhere((f) => f.key == 'condition');
      expect(condField.readFrom(item), 'Mint');

      final updated = condField.writeTo(item, 'Near Mint');
      expect(updated.condition, 'Near Mint');

      final priceField = TransferableField.universalBuiltIn
          .firstWhere((f) => f.key == 'pricePaidCents');
      expect(priceField.readFrom(item), '450');

      final updatedPrice = priceField.writeTo(item, '600');
      expect(updatedPrice.pricePaidCents, 600);
    });

    test('supports custom fields', () {
      final customDef = CustomFieldDefinition(
        id: 'cf-box',
        name: 'Storage Box',
        fieldType: 'text',
        createdAt: DateTime(2026, 1, 1),
      );

      final fields = TransferableField.withCustomFields([customDef]);
      final customField = fields.firstWhere((f) => f.key == 'cf_cf-box');

      expect(customField.isCustomField, isTrue);
      expect(customField.customFieldId, 'cf-box');
      expect(customField.label, 'Storage Box');
    });
  });

  group('Kind-owned Transfer Capabilities', () {
    test('comic kind provides comic-specific transferable fields', () {
      final comicKind = libraryKindRuntimeForKind(CatalogMediaKind.comic);
      final fields = comicKind.transfer.fieldsWithCustomFields(
        const [],
        LibraryEditScope.all,
      );

      final keys = fields.map((f) => f.key).toSet();
      expect(
          keys,
          containsAll([
            'rawOrSlabbed',
            'gradingCompany',
            'graderNotes',
            'signedBy',
            'keyComic'
          ]));

      final keyComicField = fields.firstWhere((f) => f.key == 'keyComic');
      final item = OwnedItem(
        id: 'c-1',
        catalogRef: const CatalogEntityRef(
          id: 'c-1',
          kind: 'comic',
          entityType: CatalogEntityType.work,
        ),
        details: const ComicOwnedDetails(keyComic: true),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(keyComicField.readFrom(item), 'true');
      final updated = keyComicField.writeTo(item, 'false');
      expect((updated.details as ComicOwnedDetails).keyComic, isFalse);
    });

    test('movie kind provides movie-specific transferable fields', () {
      final movieKind = libraryKindRuntimeForKind(CatalogMediaKind.movie);
      final fields = movieKind.transfer.fieldsWithCustomFields(
        const [],
        LibraryEditScope.all,
      );

      final keys = fields.map((f) => f.key).toSet();
      expect(keys, containsAll(['features', 'boxSetName', 'packaging']));

      final packagingField = fields.firstWhere((f) => f.key == 'packaging');
      final item = OwnedItem(
        id: 'm-1',
        catalogRef: const CatalogEntityRef(
          id: 'm-1',
          kind: 'movie',
          entityType: CatalogEntityType.work,
        ),
        details: const MovieOwnedDetails(packaging: 'Steelbook'),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(packagingField.readFrom(item), 'Steelbook');
      final updated = packagingField.writeTo(item, 'Digipak');
      expect((updated.details as MovieOwnedDetails).packaging, 'Digipak');
    });
  });
}
