import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_artist_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_facts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MusicWorkspaceFacts', () {
    test('builds exact distinct facts from a mixed-disc edition', () {
      final album = _mixedDiscEdition();
      final facts = MusicWorkspaceData.fromMusic(album).facts;

      expect(facts.formatSummary, '2× CD + 1× Vinyl');
      expect(facts.discCount, 3);
      expect(facts.trackCount, 0);
      expect(facts.discFormats, {'CD', 'Vinyl'});
      expect(facts.discFormatFamilies, {
        MusicDiscFormatFamily.opticalDisc,
        MusicDiscFormatFamily.vinyl,
      });
      expect(facts.discRecordingYears, {2024, 2025, 2026});
      expect(facts.discRecordingMonths, {2});
      expect(facts.discSparsCodes, isEmpty);
      expect(facts.discSoundTypes, {'DDD', 'ADD'});
      expect(facts.discColors, {'Red'});
      expect(facts.discRpms, {'45'});
      expect(facts.recordingLocations, {'Abbey Road', 'Wembley'});
      expect(facts.hasLiveDisc, isTrue);
      expect(facts.hasStudioDisc, isTrue);
      expect(facts.earliestDiscRecordingDate?.isoString, '2024');
      expect(facts.latestDiscRecordingDate?.isoString, '2026-02-18');
      expect(facts.albumContributors, {'The Beatles'});
      expect(facts.discContributors, {'John', 'Jane', 'LSO'});
      expect(facts.allContributors, {'The Beatles', 'John', 'Jane', 'LSO'});
      expect(facts.creditRoles, {'Producer', 'Conductor', 'Orchestra'});
      expect(facts.creditInstruments, {'Piano'});
      expect(facts.contributorsForRole('producer'), {'John'});
      expect(facts.contributorsForRole('conductor'), {'Jane'});
    });

    test('reduces partial dates using start and end bounds', () {
      final album = MusicAlbum(
        title: 'Partial dates',
        discs: [
          _disc('year-only', 1, recordingDate: const PartialDate(year: 1995)),
          _disc(
            'month-only',
            2,
            recordingDate: const PartialDate(year: 1995, month: 4),
          ),
        ],
      );
      final facts = MusicWorkspaceData.fromMusic(album).facts;

      expect(facts.earliestDiscRecordingDate?.isoString, '1995');
      expect(facts.latestDiscRecordingDate?.isoString, '1995');

      final sameMonthAlbum = MusicAlbum(
        title: 'Same month',
        discs: [
          _disc(
            'month-only',
            1,
            recordingDate: const PartialDate(year: 1995, month: 4),
          ),
          _disc(
            'full-date',
            2,
            recordingDate: const PartialDate(year: 1995, month: 4, day: 21),
          ),
        ],
      );
      final sameMonthFacts = MusicWorkspaceData.fromMusic(sameMonthAlbum).facts;

      expect(sameMonthFacts.earliestDiscRecordingDate?.isoString, '1995-04');
      expect(sameMonthFacts.latestDiscRecordingDate?.isoString, '1995-04');
    });

    test('compares partial date bounds consistently for earliest and latest',
        () {
      const year = PartialDate(year: 1995);
      const april = PartialDate(year: 1995, month: 4);

      expect(
        compareMusicPartialDateBounds(year, april, latest: false),
        lessThan(0),
      );
      expect(
        compareMusicPartialDateBounds(year, april, latest: true),
        greaterThan(0),
      );
    });

    test('keeps album and disc contributor scopes in distinct sets', () {
      final album = MusicAlbum(
        title: 'Scoped credits',
        credits: [_credit('album-credit', 'Album Producer', 'Producer')],
        discs: [
          _disc(
            'disc-1',
            1,
            credits: [_credit('disc-credit', 'Disc Conductor', 'Conductor')],
          ),
        ],
      );
      final facts = MusicWorkspaceData.fromMusic(album).facts;

      expect(facts.albumContributors, {'Album Producer'});
      expect(facts.discContributors, {'Disc Conductor'});
      expect(facts.allContributors, {'Album Producer', 'Disc Conductor'});
      expect(facts.creditRoles, {'Producer', 'Conductor'});
    });

    test('workspace data reuses its immutable fact snapshot', () {
      final data = MusicWorkspaceData.fromMusic(_mixedDiscEdition());
      final copied = data.copyWith();

      expect(identical(copied.facts, data.facts), isTrue);
      expect(
          () => data.facts.discFormats.add('MiniDisc'), throwsUnsupportedError);
      expect(() => data.facts.contributorsByRole['producer']!.add('Other'),
          throwsUnsupportedError);
    });
  });
}

MusicAlbum _mixedDiscEdition() => MusicAlbum(
      title: 'Deluxe Edition',
      artistCredits: const [
        MusicArtistCredit(
          id: 'artist-credit-1',
          creditedName: 'The Beatles',
          sequence: 1,
        ),
      ],
      discs: [
        _disc(
          'disc-cd-1',
          1,
          family: MusicDiscFormatFamily.opticalDisc,
          format: 'CD',
          recordingDate: const PartialDate(year: 2025),
          recordingLocations: const ['Abbey Road', 'Abbey Road'],
          soundTypes: const ['DDD', 'DDD'],
          isLive: false,
          credits: [_credit('credit-producer-john', 'John', 'Producer')],
        ),
        _disc(
          'disc-cd-2',
          2,
          family: MusicDiscFormatFamily.opticalDisc,
          format: 'CD',
          recordingDate: const PartialDate(year: 2026, month: 2, day: 18),
          recordingLocations: const ['Wembley'],
          soundTypes: const ['ADD'],
          isLive: true,
          credits: [
            _credit(
              'credit-conductor-jane',
              'Jane',
              'Conductor',
              instruments: const ['Piano'],
            ),
            _credit('credit-orchestra-lso', 'LSO', 'Orchestra'),
          ],
        ),
        _disc(
          'disc-vinyl',
          3,
          family: MusicDiscFormatFamily.vinyl,
          format: 'Vinyl',
          recordingDate: const PartialDate(year: 2024),
          color: 'Red',
          rpm: '45',
        ),
      ],
    );

MusicDisc _disc(
  String id,
  int number, {
  MusicDiscFormatFamily? family,
  String? format,
  PartialDate? recordingDate,
  List<String> recordingLocations = const [],
  List<String> soundTypes = const [],
  bool? isLive,
  String? color,
  String? rpm,
  List<MusicCredit> credits = const [],
}) =>
    MusicDisc(
      id: MusicDiscId(id),
      discNumber: number,
      formatFamily: family,
      format: format,
      recordingDate: recordingDate,
      recordingLocations: recordingLocations,
      soundTypes: soundTypes,
      isLive: isLive,
      color: color,
      rpm: rpm,
      credits: credits,
    );

MusicCredit _credit(
  String id,
  String name,
  String role, {
  List<String> instruments = const [],
}) =>
    MusicCredit(
      id: MusicCreditId(id),
      name: name,
      role: role,
      instruments: instruments,
      sequence: 1,
    );
