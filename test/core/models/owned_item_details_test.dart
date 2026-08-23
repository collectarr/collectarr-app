import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OwnedItemDetails Round-trip Tests (Task 10)', () {
    test('ComicOwnedDetails serializes and deserializes correctly', () {
      final details = ComicOwnedDetails(
        rawOrSlabbed: 'slabbed',
        gradingCompany: 'CGC',
        keyComic: true,
        keyReason: 'First appearance of Venom',
        coverPriceCents: 150,
      );

      final json = details.toJson();
      final restored = ComicOwnedDetails.fromJson(json);

      expect(restored.rawOrSlabbed, 'slabbed');
      expect(restored.gradingCompany, 'CGC');
      expect(restored.keyComic, isTrue);
      expect(restored.keyReason, 'First appearance of Venom');
      expect(restored.coverPriceCents, 150);
      expect(restored.isSlabbed, isTrue);
    });

    test('MovieOwnedDetails serializes and deserializes correctly', () {
      final details = const MovieOwnedDetails(
        features: 'Director Cut',
        hdrFormats: ['HDR10', 'Dolby Vision'],
        region: 'A',
        packaging: 'SteelBook',
      );

      final json = details.toJson();
      final restored = MovieOwnedDetails.fromJson(json);

      expect(restored.features, 'Director Cut');
      expect(restored.hdrFormats, ['HDR10', 'Dolby Vision']);
      expect(restored.region, 'A');
      expect(restored.packaging, 'SteelBook');
    });

    test('GameOwnedDetails serializes and deserializes correctly', () {
      final details = const GameOwnedDetails(
        completeness: 'CIB',
        hasBox: true,
        hasManual: true,
        priceChartingId: '12345',
        coreRegion: 'NTSC-U',
        valueIsLocked: true,
      );

      final json = details.toJson();
      final restored = GameOwnedDetails.fromJson(json);

      expect(restored.completeness, 'CIB');
      expect(restored.hasBox, isTrue);
      expect(restored.hasManual, isTrue);
      expect(restored.priceChartingId, '12345');
      expect(restored.coreRegion, 'NTSC-U');
      expect(restored.valueIsLocked, isTrue);
    });

    test('MusicOwnedDetails serializes and deserializes correctly', () {
      final details = const MusicOwnedDetails(
        storageDevice: 'Shelf A',
        storageSlot: 'Slot 12',
      );

      final json = details.toJson();
      final restored = MusicOwnedDetails.fromJson(json);

      expect(restored.storageDevice, 'Shelf A');
      expect(restored.storageSlot, 'Slot 12');
    });
  });
}
