import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CatalogDisc', () {
    test('fromJson parses all fields', () {
      final disc = CatalogDisc.fromJson({
        'disc_number': 2,
        'name': 'Bonus Features',
      });
      expect(disc.discNumber, 2);
      expect(disc.discName, 'Bonus Features');
    });

    test('fromJson handles empty json', () {
      final disc = CatalogDisc.fromJson({});
      expect(disc.discNumber, isNull);
      expect(disc.discName, isNull);
    });

    test('toJson roundtrips', () {
      const disc = CatalogDisc(
        discNumber: 3,
        name: 'DVD Extras',
      );
      final json = disc.toJson();
      expect(json['disc_number'], 3);
      expect(json['name'], 'DVD Extras');

      final restored = CatalogDisc.fromJson(json);
      expect(restored.discNumber, disc.discNumber);
      expect(restored.discName, disc.discName);
    });

    test('toJson omits null fields', () {
      const disc = CatalogDisc(discNumber: 1);
      final json = disc.toJson();
      expect(json.containsKey('name'), isFalse);
    });
  });

  group('CatalogEdition with discs', () {
    test('fromJson parses discs array', () {
      final edition = CatalogEdition.fromJson({
        'id': 'ed-1',
        'title': '4K Collector',
        'discs': [
          {'disc_number': 1, 'name': 'Feature Film'},
          {'disc_number': 2, 'name': 'Bonus'},
        ],
        'variants': <dynamic>[],
      });
      expect(edition.discs.length, 2);
      expect(edition.discs[0].discName, 'Feature Film');
    });

    test('fromJson defaults to empty discs', () {
      final edition = CatalogEdition.fromJson({
        'id': 'ed-2',
        'title': 'Standard',
      });
      expect(edition.discs, isEmpty);
    });

    test('toJson includes discs when non-empty', () {
      const edition = CatalogEdition(
        id: 'ed-3',
        title: 'Deluxe',
        discs: [CatalogDisc(discNumber: 1, name: 'Main')],
      );
      final json = edition.toJson();
      expect(json['discs'], isA<List<dynamic>>());
      expect((json['discs'] as List).length, 1);
    });

    test('toJson omits discs when empty', () {
      const edition = CatalogEdition(id: 'ed-4', title: 'Basic');
      final json = edition.toJson();
      expect(json.containsKey('discs'), isFalse);
    });
  });
}
