import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_format_presets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MusicDisc format and recording metadata', () {
    test('serializes technical and recording metadata on the disc', () {
      final disc = MusicDisc(
        id: const MusicDiscId('disc-1'),
        discNumber: 1,
        title: 'Side A/B',
        formatFamily: MusicDiscFormatFamily.vinyl,
        format: 'Vinyl (12" LP)',
        soundTypes: const ['Stereo', 'Dolby Atmos'],
        recordingDate: PartialDate(year: 2025, month: 2),
        recordingLocations: const ['Abbey Road', 'Wembley'],
        isLive: true,
        sparsCode: 'DDD',
        color: 'Clear Splatter',
        vinylWeightGrams: 180,
        rpm: '45',
        matrixNumberSideA: 'MAT-A-1',
        matrixNumberSideB: 'MAT-B-1',
        credits: [
          MusicCredit(
            id: const MusicCreditId('credit-1'),
            contributorId: null,
            name: 'Jane Doe',
            role: 'Producer',
            instruments: const ['Piano', 'Voice'],
            sequence: 1,
          ),
        ],
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
      expect(json['recording_date'], {'year': 2025, 'month': 2});
      expect(json['recording_locations'], ['Abbey Road', 'Wembley']);
      expect(json['is_live'], isTrue);
      expect(json['spars_code'], 'DDD');
      final credit =
          (json['credits'] as List).cast<Map<String, dynamic>>().single;
      expect(credit['contributor_id'], isNull);
      expect(
        credit['instruments'],
        ['Piano', 'Voice'],
      );

      final reconstructed = MusicDisc.fromJson(json);
      expect(reconstructed.recordingDate?.isoString, '2025-02');
      expect(reconstructed.recordingLocations, ['Abbey Road', 'Wembley']);
      expect(reconstructed.credits.single.contributorId, isNull);
      expect(reconstructed.credits.single.instruments, ['Piano', 'Voice']);
      expect(reconstructed.tracks.single.id.value, 'track-1');
    });

    test('format summary counts contained disc formats', () {
      expect(formatAlbumDiscsSummary([]), isNull);
      expect(formatAlbumDiscsSummary([], fallback: 'CD'), 'CD');
      expect(
        formatAlbumDiscsSummary([
          MusicDisc(id: const MusicDiscId('1'), discNumber: 1, format: 'CD'),
        ]),
        'CD',
      );
      expect(
        formatAlbumDiscsSummary([
          MusicDisc(id: const MusicDiscId('1'), discNumber: 1, format: 'CD'),
          MusicDisc(id: const MusicDiscId('2'), discNumber: 2, format: 'CD'),
          MusicDisc(id: const MusicDiscId('3'), discNumber: 3, format: 'Vinyl'),
        ]),
        '2× CD + 1× Vinyl',
      );
    });

    test(
        'album stores edition metadata while all recording data belongs to discs',
        () {
      final album = MusicAlbum(
        id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-1'),
        title: 'Deluxe Edition',
        publisher: 'Example Label',
        releaseDateParts: PartialDate(year: 2025),
        discs: [
          MusicDisc(
            id: const MusicDiscId('cd-1'),
            discNumber: 1,
            format: 'CD',
            formatFamily: MusicDiscFormatFamily.opticalDisc,
            recordingDate: PartialDate(year: 2025),
            recordingLocations: const ['Abbey Road'],
            isLive: false,
            sparsCode: 'DDD',
          ),
          MusicDisc(
            id: const MusicDiscId('vinyl-1'),
            discNumber: 2,
            format: 'Vinyl',
            formatFamily: MusicDiscFormatFamily.vinyl,
            recordingDate: PartialDate(year: 2024),
            isLive: true,
          ),
        ],
      );

      expect(album.formatSummary, '1× CD + 1× Vinyl');
      expect(album.discs.map((disc) => disc.sparsCode).whereType<String>(),
          ['DDD']);
      expect(album.toJson(), isNot(contains('recording_date')));
      expect(album.toJson(), isNot(contains('is_live')));
      expect(album.toJson(), isNot(contains('spars_code')));
    });

    test('edit draft applies changes to disc scope and keeps family explicit',
        () {
      final album = MusicAlbum(
        id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-2'),
        title: 'Draft Test',
        discs: [
          MusicDisc(
            id: const MusicDiscId('disc-1'),
            discNumber: 1,
            format: 'CD',
            formatFamily: MusicDiscFormatFamily.opticalDisc,
          ),
        ],
      );
      final draft = MusicAlbumEditDraft.fromAlbum(album);

      draft.discList.updateDiscFormat(
        const MusicDiscId('disc-1'),
        'Vinyl',
        formatFamily: MusicDiscFormatFamily.vinyl,
      );
      draft.discList.updateDiscColor(const MusicDiscId('disc-1'), 'Blue');
      draft.discList
          .updateDiscVinylWeightGrams(const MusicDiscId('disc-1'), 180);
      draft.discList.updateDiscRpm(const MusicDiscId('disc-1'), '45');
      draft.discList.updateDiscSoundTypes(
        const MusicDiscId('disc-1'),
        ['Stereo'],
      );
      draft.discList.updateDiscRecordingDate(
        const MusicDiscId('disc-1'),
        PartialDate(year: 2026, month: 2, day: 18),
      );
      draft.discList.updateDiscRecordingLocations(
        const MusicDiscId('disc-1'),
        ['Wembley'],
      );
      draft.discList.updateDiscIsLive(const MusicDiscId('disc-1'), true);
      draft.discList.updateDiscSparsCode(const MusicDiscId('disc-1'), 'ADD');
      expect(draft.formatSummary, 'Vinyl');

      draft.discList.addDisc(
        format: 'SHM-CD',
        formatFamily: musicFormatPresetFamily('SHM-CD'),
      );
      final saved = draft.toAlbum();
      expect(saved.discs, hasLength(2));
      expect(saved.discs.first.formatFamily, MusicDiscFormatFamily.vinyl);
      expect(saved.discs.first.sparsCode, 'ADD');
      expect(saved.discs.first.recordingLocations, ['Wembley']);
      expect(saved.discs.last.formatFamily, MusicDiscFormatFamily.opticalDisc);
      expect(saved.formatSummary, '1× Vinyl + 1× SHM-CD');
    });

    test(
        'known formats use explicit presets; custom formats do not infer a family',
        () {
      expect(musicFormatPresetFamily('CD'), MusicDiscFormatFamily.opticalDisc);
      expect(
          musicFormatPresetFamily('SACD'), MusicDiscFormatFamily.opticalDisc);
      expect(musicFormatPresetFamily('Cassette'), MusicDiscFormatFamily.tape);
      expect(musicFormatPresetFamily('FLAC'), MusicDiscFormatFamily.digital);
      expect(musicFormatPresetFamily('custom silver disc'), isNull);
    });

    test('strict domain rejects former album-level recording fields', () {
      expect(
        () => MusicAlbum.fromJson({
          'title': 'Old payload',
          'spars_code': 'DDD',
        }),
        throwsFormatException,
      );
      expect(
        () => MusicAlbum.fromJson({
          'title': 'Old payload',
          'composers': <Object?>[],
        }),
        throwsFormatException,
      );
    });
  });
}
