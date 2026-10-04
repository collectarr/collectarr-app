import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Typed TransferableField', () {
    test('reads and writes typed Book fields', () {
      final item = BookLibraryEntry(
        id: LibraryEntryId('item-1'),
        catalogRef: const CatalogEntityRef(
          id: 'work-1',
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId.catalogItem,
        ),
        condition: 'Mint',
        grade: '9.8',
        personalNotes: 'First print run',
        pricePaidCents: 450,
        updatedAt: DateTime(2026, 1, 1),
      );

      final fields = libraryTransferForKind(CatalogMediaKind.book)
          .fieldsWithCustomFields(const []);
      final condField = fields.firstWhere((f) => f.key == 'condition');
      expect(condField.readFrom(item), 'Mint');

      final updated = condField.writeTo(item, 'Near Mint') as BookLibraryEntry;
      expect(updated.condition, 'Near Mint');

      final priceField = fields.firstWhere((f) => f.key == 'pricePaidCents');
      expect(priceField.readFrom(item), '450');

      final updatedPrice = priceField.writeTo(item, '600') as BookLibraryEntry;
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

  group('Kind-entry Transfer Capabilities', () {
    test('comic kind provides comic-specific transferable fields', () {
      final fields =
          libraryTransferForKind(CatalogMediaKind.comic).fieldsWithCustomFields(
        const [],
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
      final item = ComicLibraryEntry(
        id: LibraryEntryId('c-1'),
        catalogRef: const CatalogEntityRef(
          id: 'c-1',
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId.catalogItem,
        ),
        details: const ComicEntryDetails(keyComic: true),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(keyComicField.readFrom(item), 'true');
      final updated = keyComicField.writeTo(item, 'false') as ComicLibraryEntry;
      expect(updated.details.keyComic, isFalse);
    });

    test('movie kind provides movie-specific transferable fields', () {
      final fields =
          libraryTransferForKind(CatalogMediaKind.movie).fieldsWithCustomFields(
        const [],
      );

      final keys = fields.map((f) => f.key).toSet();
      expect(keys, containsAll(['features', 'boxSetName', 'packaging']));

      final packagingField = fields.firstWhere((f) => f.key == 'packaging');
      final item = MovieLibraryEntry(
        id: LibraryEntryId('m-1'),
        catalogRef: const CatalogEntityRef(
          id: 'm-1',
          kind: CatalogMediaKind.movie,
          entityType: CatalogEntityTypeId.catalogItem,
        ),
        details: const MovieEntryDetails(packaging: 'Steelbook'),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(packagingField.readFrom(item), 'Steelbook');
      final updated = packagingField.writeTo(item, 'Digipak') as MovieLibraryEntry;
      expect(updated.details.packaging, 'Digipak');
    });
  });
}
