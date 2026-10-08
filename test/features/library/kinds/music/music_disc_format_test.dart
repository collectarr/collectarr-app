import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MusicDisc format and physical metadata', () {
    test('serializes and deserializes disc format, vinyl, sound, and matrix numbers', () {
      final disc = MusicDisc(
        id: const MusicDiscId('disc-1'),
        discNumber: 1,
        title: 'Side A/B',
        formatFamily: MusicDiscFormatFamily.vinyl,
        format: 'Vinyl (12" LP)',
        soundTypes: const ['Stereo', 'Dolby Atmos'],
        color: 'Clear Splatter',
        vinylWeightGrams: 180,
        rpm: '45',
        matrixNumberSideA: 'MAT-A-1',
        matrixNumberSideB: 'MAT-B-1',
        tracks: [
          MusicTrack(
            id: const MusicTrackId('track-1'),
            position: '1',
            title: 'Song One',
          ),
        ],
      );

      final json = disc.toJson();
      expect(json['format_family'], 'vinyl');
      expect(json['format'], 'Vinyl (12" LP)');
      expect(json['sound_types'], ['Stereo', 'Dolby Atmos']);
      expect(json['color'], 'Clear Splatter');
      expect(json['vinyl_weight_grams'], 180);
      expect(json['rpm'], '45');
      expect(json['matrix_number_side_a'], 'MAT-A-1');

      final reconstructed = MusicDisc.fromJson(json);
      expect(reconstructed.id.value, 'disc-1');
      expect(reconstructed.formatFamily, MusicDiscFormatFamily.vinyl);
      expect(reconstructed.format, 'Vinyl (12" LP)');
      expect(reconstructed.soundTypes, ['Stereo', 'Dolby Atmos']);
      expect(reconstructed.color, 'Clear Splatter');
      expect(reconstructed.vinylWeightGrams, 180);
      expect(reconstructed.rpm, '45');
      expect(reconstructed.matrixNumberSideA, 'MAT-A-1');
      expect(reconstructed.tracks.length, 1);
    });

    test('formatAlbumDiscsSummary and formatDiscsSummary correctly aggregate formats', () {
      expect(
        formatAlbumDiscsSummary([]),
        isNull,
      );
      expect(
        formatAlbumDiscsSummary([], fallback: 'CD'),
        'CD',
      );

      final singleCd = [
        MusicDisc(id: const MusicDiscId('1'), discNumber: 1, format: 'CD'),
      ];
      expect(formatAlbumDiscsSummary(singleCd), 'CD');

      final doubleVinyl = [
        MusicDisc(id: const MusicDiscId('1'), discNumber: 1, format: 'Vinyl'),
        MusicDisc(id: const MusicDiscId('2'), discNumber: 2, format: 'Vinyl'),
      ];
      expect(formatAlbumDiscsSummary(doubleVinyl), '2× Vinyl');

      final mixedBox = [
        MusicDisc(id: const MusicDiscId('1'), discNumber: 1, format: 'CD'),
        MusicDisc(id: const MusicDiscId('2'), discNumber: 2, format: 'CD'),
        MusicDisc(id: const MusicDiscId('3'), discNumber: 3, format: 'Vinyl'),
      ];
      expect(formatAlbumDiscsSummary(mixedBox), '2× CD + 1× Vinyl');
    });

    test('MusicAlbum derives formatSummary from discs and keeps sparsCode at album level', () {
      final album = MusicAlbum(
        id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'alb-1'),
        title: 'Test Album',
        sparsCode: 'DSD',
        discs: [
          MusicDisc(
            id: const MusicDiscId('1'),
            discNumber: 1,
            format: 'SACD',
            soundTypes: const ['Stereo', '5.1 Surround'],
          ),
          MusicDisc(
            id: const MusicDiscId('2'),
            discNumber: 2,
            format: 'CD',
            soundTypes: const ['Stereo'],
          ),
        ],
      );

      expect(album.formatSummary, '1× SACD + 1× CD');
      expect(album.sparsCode, 'DSD');
    });

    test('MusicAlbumEditDraft manages disc-level formats and updates derived summary', () {
      final album = MusicAlbum(
        id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'alb-2'),
        title: 'Draft Test',
        sparsCode: 'AAA',
        discs: [
          MusicDisc(
            id: const MusicDiscId('d-1'),
            discNumber: 1,
            format: 'CD',
            formatFamily: MusicDiscFormatFamily.cd,
          ),
        ],
      );

      final draft = MusicAlbumEditDraft.fromAlbum(album);
      expect(draft.formatSummary, 'CD');

      // Update disc 1 format and physical details
      draft.updateDiscFormat(const MusicDiscId('d-1'), 'Vinyl');
      draft.updateDiscFormatFamily(
        const MusicDiscId('d-1'),
        MusicDiscFormatFamily.vinyl,
      );
      draft.updateDiscColor(const MusicDiscId('d-1'), 'Blue');
      draft.updateDiscVinylWeightGrams(const MusicDiscId('d-1'), 180);
      draft.updateDiscRpm(const MusicDiscId('d-1'), '33⅓');
      draft.updateDiscSoundTypes(const MusicDiscId('d-1'), ['Stereo']);

      expect(draft.formatSummary, 'Vinyl');
      expect(draft.discs.first.color, 'Blue');
      expect(draft.discs.first.vinylWeightGrams, 180);
      expect(draft.discs.first.rpm, '33⅓');
      expect(draft.values.sparsCode, 'AAA');

      // Add second disc
      draft.addDisc(
        format: 'Vinyl',
        formatFamily: MusicDiscFormatFamily.vinyl,
      );
      expect(draft.discs.length, 2);
      expect(draft.formatSummary, '2× Vinyl');

      // Save to album
      final updatedAlbum = draft.toAlbum();
      expect(updatedAlbum.formatSummary, '2× Vinyl');
      expect(updatedAlbum.discs.length, 2);
      expect(updatedAlbum.discs[0].color, 'Blue');
      expect(updatedAlbum.discs[0].rpm, '33⅓');
      expect(updatedAlbum.discs[1].format, 'Vinyl');
    });
  });
}
