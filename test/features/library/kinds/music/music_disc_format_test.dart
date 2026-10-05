import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MusicDisc format and physical metadata', () {
    test('serializes and deserializes disc format, vinyl, sound, and spars', () {
      final disc = MusicDisc(
        id: const MusicDiscId('disc-1'),
        discNumber: 1,
        title: 'Side A/B',
        format: 'Vinyl',
        soundTypes: const ['Stereo', 'Dolby Atmos'],
        vinylColor: 'Clear Splatter',
        vinylWeight: '180',
        rpm: 45,
        spars: 'AAA',
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
      expect(json['format'], 'Vinyl');
      expect(json['sound_types'], ['Stereo', 'Dolby Atmos']);
      expect(json['vinyl_color'], 'Clear Splatter');
      expect(json['vinyl_weight'], '180');
      expect(json['rpm'], 45);
      expect(json['spars'], 'AAA');
      expect(json['matrix_number_side_a'], 'MAT-A-1');

      final reconstructed = MusicDisc.fromJson(json);
      expect(reconstructed.id.value, 'disc-1');
      expect(reconstructed.format, 'Vinyl');
      expect(reconstructed.soundTypes, ['Stereo', 'Dolby Atmos']);
      expect(reconstructed.vinylColor, 'Clear Splatter');
      expect(reconstructed.vinylWeight, '180');
      expect(reconstructed.rpm, 45);
      expect(reconstructed.spars, 'AAA');
      expect(reconstructed.matrixNumberSideA, 'MAT-A-1');
      expect(reconstructed.tracks.length, 1);
    });

    test('formatAlbumDiscsSummary correctly aggregates formats', () {
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

    test('MusicAlbum derives format and disc properties from discs', () {
      final album = MusicAlbum(
        id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'alb-1'),
        title: 'Test Album',
        discs: [
          MusicDisc(
            id: const MusicDiscId('1'),
            discNumber: 1,
            format: 'SACD',
            soundTypes: const ['Stereo', '5.1 Surround'],
            spars: 'DSD',
          ),
          MusicDisc(
            id: const MusicDiscId('2'),
            discNumber: 2,
            format: 'CD',
            soundTypes: const ['Stereo'],
            spars: 'DDD',
          ),
        ],
      );

      expect(album.format, '1× SACD + 1× CD');
      expect(album.soundTypes, containsAll(['Stereo', '5.1 Surround']));
      expect(album.spars, 'DSD');
    });

    test('MusicAlbum.fromJson migrates legacy album-level fields to disc 1', () {
      final legacyJson = {
        'id': 'legacy-1',
        'title': 'Legacy Pressing',
        'format': 'Vinyl',
        'sound_types': ['Stereo'],
        'vinyl_color': 'Red',
        'vinyl_weight': '180',
        'rpm': 33,
        'spars': 'AAD',
        'discs': [
          {
            'id': 'd-1',
            'disc_number': 1,
            'tracks': <Map<String, dynamic>>[],
          }
        ],
      };

      final album = MusicAlbum.fromJson(legacyJson);
      expect(album.discs.length, 1);
      final disc1 = album.discs.first;
      expect(disc1.format, 'Vinyl');
      expect(disc1.vinylColor, 'Red');
      expect(disc1.vinylWeight, '180');
      expect(disc1.rpm, 33);
      expect(disc1.spars, 'AAD');
      expect(disc1.soundTypes, ['Stereo']);
      expect(album.format, 'Vinyl');
    });

    test('MusicAlbumEditDraft manages disc-level formats and updates derived summary', () {
      final album = MusicAlbum(
        id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'alb-2'),
        title: 'Draft Test',
        discs: [
          MusicDisc(
            id: const MusicDiscId('d-1'),
            discNumber: 1,
            format: 'CD',
          ),
        ],
      );

      final draft = MusicAlbumEditDraft.fromAlbum(album);
      expect(draft.values.format, 'CD');

      // Update disc 1 format
      draft.updateDiscFormat(const MusicDiscId('d-1'), 'Vinyl');
      draft.updateDiscVinylDetails(
        const MusicDiscId('d-1'),
        vinylColor: 'Blue',
        replaceVinylColor: true,
        vinylWeight: '180',
        replaceVinylWeight: true,
        rpm: 33,
        replaceRpm: true,
      );
      draft.updateDiscSoundTypes(const MusicDiscId('d-1'), ['Stereo']);
      draft.updateDiscSpars(const MusicDiscId('d-1'), 'AAA');

      expect(draft.values.format, 'Vinyl');
      expect(draft.discs.first.vinylColor, 'Blue');
      expect(draft.discs.first.vinylWeight, '180');
      expect(draft.discs.first.rpm, 33);
      expect(draft.discs.first.spars, 'AAA');

      // Add second disc
      draft.addDisc(format: 'Vinyl');
      expect(draft.discs.length, 2);
      expect(draft.values.format, '2× Vinyl');

      // Save to album
      final updatedAlbum = draft.toAlbum();
      expect(updatedAlbum.format, '2× Vinyl');
      expect(updatedAlbum.discs.length, 2);
      expect(updatedAlbum.discs[0].vinylColor, 'Blue');
      expect(updatedAlbum.discs[0].rpm, 33);
      expect(updatedAlbum.discs[1].format, 'Vinyl');
    });
  });
}
