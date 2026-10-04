import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kind-entry details round trips', () {
    test('ComicEntryDetails serializes and deserializes correctly', () {
      final details = ComicEntryDetails(
        rawOrSlabbed: 'slabbed',
        gradingCompany: 'CGC',
        keyComic: true,
        keyReason: 'First appearance of Venom',
        coverPriceCents: 150,
      );

      final json = details.toJson();
      final restored = ComicEntryDetails.fromJson(json);

      expect(restored.rawOrSlabbed, 'slabbed');
      expect(restored.gradingCompany, 'CGC');
      expect(restored.keyComic, isTrue);
      expect(restored.keyReason, 'First appearance of Venom');
      expect(restored.coverPriceCents, 150);
      expect(restored.isSlabbed, isTrue);
    });

    test('MovieEntryDetails serializes and deserializes correctly', () {
      final details = const MovieEntryDetails(
        features: 'Director Cut',
        hdrFormats: ['HDR10', 'Dolby Vision'],
        region: 'A',
        packaging: 'SteelBook',
      );

      final json = details.toJson();
      final restored = MovieEntryDetails.fromJson(json);

      expect(restored.features, 'Director Cut');
      expect(restored.hdrFormats, ['HDR10', 'Dolby Vision']);
      expect(restored.region, 'A');
      expect(restored.packaging, 'SteelBook');
    });

    test('GameEntryDetails serializes and deserializes correctly', () {
      final details = const GameEntryDetails(
        completeness: 'CIB',
        hasBox: true,
        hasManual: true,
        priceChartingId: '12345',
        coreRegion: 'NTSC-U',
        valueIsLocked: true,
      );

      final json = details.toJson();
      final restored = GameEntryDetails.fromJson(json);

      expect(restored.completeness, 'CIB');
      expect(restored.hasBox, isTrue);
      expect(restored.hasManual, isTrue);
      expect(restored.priceChartingId, '12345');
      expect(restored.coreRegion, 'NTSC-U');
      expect(restored.valueIsLocked, isTrue);
    });

    test('MusicEntryDetails serializes and deserializes correctly', () {
      final details = const MusicEntryDetails(
        media: [
          MusicEntryMediumDetails(
            mediumIndex: 1,
            storageDevice: 'Shelf A',
            storageSlot: 'Slot 12',
          ),
        ],
      );

      final json = details.toJson();
      final restored = MusicEntryDetails.fromJson(json);

      expect(restored.media.single.storageDevice, 'Shelf A');
      expect(restored.media.single.storageSlot, 'Slot 12');
    });
  });
}
