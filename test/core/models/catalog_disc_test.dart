import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CatalogDisc', () {
    test('fromJson parses all fields', () {
      final disc = CatalogDisc.fromJson({
        'disc_number': 2,
        'disc_name': 'Bonus Features',
        'disc_format': 'Blu-ray',
      });
      expect(disc.discNumber, 2);
      expect(disc.discName, 'Bonus Features');
      expect(disc.discFormat, 'Blu-ray');
    });

    test('fromJson defaults disc_number to 1', () {
      final disc = CatalogDisc.fromJson({});
      expect(disc.discNumber, 1);
      expect(disc.discName, isNull);
      expect(disc.discFormat, isNull);
    });

    test('toJson roundtrips', () {
      const disc = CatalogDisc(
        discNumber: 3,
        discName: 'DVD Extras',
        discFormat: 'DVD',
      );
      final json = disc.toJson();
      expect(json['disc_number'], 3);
      expect(json['disc_name'], 'DVD Extras');
      expect(json['disc_format'], 'DVD');

      final restored = CatalogDisc.fromJson(json);
      expect(restored.discNumber, disc.discNumber);
      expect(restored.discName, disc.discName);
      expect(restored.discFormat, disc.discFormat);
    });

    test('toJson omits null fields', () {
      const disc = CatalogDisc(discNumber: 1);
      final json = disc.toJson();
      expect(json.containsKey('disc_name'), isFalse);
      expect(json.containsKey('disc_format'), isFalse);
    });
  });

  group('CatalogEdition with discs', () {
    test('fromJson parses discs array', () {
      final edition = CatalogEdition.fromJson({
        'id': 'ed-1',
        'title': '4K Collector',
        'discs': [
          {'disc_number': 1, 'disc_name': 'Feature Film', 'disc_format': '4K UHD'},
          {'disc_number': 2, 'disc_name': 'Bonus', 'disc_format': 'Blu-ray'},
        ],
        'variants': [],
      });
      expect(edition.discs.length, 2);
      expect(edition.discs[0].discName, 'Feature Film');
      expect(edition.discs[1].discFormat, 'Blu-ray');
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
        discs: [CatalogDisc(discNumber: 1, discName: 'Main')],
      );
      final json = edition.toJson();
      expect(json['discs'], isA<List>());
      expect((json['discs'] as List).length, 1);
    });

    test('toJson omits discs when empty', () {
      const edition = CatalogEdition(id: 'ed-4', title: 'Basic');
      final json = edition.toJson();
      expect(json.containsKey('discs'), isFalse);
    });
  });
}
