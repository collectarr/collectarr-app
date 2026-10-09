import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music domain JSON round-trips the canonical nested representation', () {
    final album = MusicAlbum.fromJson(_albumJson());
    final firstEncoding = album.toJson();
    final secondEncoding = MusicAlbum.fromJson(firstEncoding).toJson();

    expect(secondEncoding, firstEncoding);
    expect(firstEncoding, containsPair('extra', ['foo', 'bar']));
    expect(firstEncoding, isNot(contains('composers')));
    expect(firstEncoding, isNot(contains('recording_date')));
    expect(firstEncoding, isNot(contains('release_date_parts')));
    expect(
      (firstEncoding['discs'] as List).single,
      containsPair('recording_date', {'year': 2025, 'month': 5}),
    );
  });

  test('Music domain rejects unknown root and nested fields', () {
    expect(
      () => MusicAlbum.fromJson({..._albumJson(), 'unknown_music_field': 1}),
      throwsFormatException,
    );

    final album = _albumJson();
    final disc =
        Map<String, Object?>.from((album['discs'] as List).single as Map)
          ..['old_disc_format'] = 'CD';
    expect(
      () => MusicAlbum.fromJson({
        ...album,
        'discs': [disc]
      }),
      throwsFormatException,
    );

    expect(
      () => MusicAlbum.fromJson({..._albumJson(), 'composers': <Object?>[]}),
      throwsFormatException,
    );
  });

  test('Music domain rejects duplicate disc identities', () {
    final first = _discJson(id: 'same-disc', number: 1);
    final second = _discJson(id: 'same-disc', number: 2);

    expect(
      () => MusicAlbum.fromJson({
        ..._albumJson(),
        'discs': [first, second]
      }),
      throwsFormatException,
    );
  });

  test('Music domain rejects duplicate track identities across discs', () {
    final first = _discJson(
      id: 'disc-one',
      number: 1,
      tracks: [_trackJson(id: 'same-track')],
    );
    final second = _discJson(
      id: 'disc-two',
      number: 2,
      tracks: [_trackJson(id: 'same-track')],
    );

    expect(
      () => MusicAlbum.fromJson({
        ..._albumJson(),
        'discs': [first, second]
      }),
      throwsFormatException,
    );
  });

  test('Music domain rejects duplicate credit identities across scopes', () {
    final credit = _creditJson(id: 'shared-credit');
    final disc = _discJson(
      id: 'disc-one',
      number: 1,
      credits: [credit],
    );

    expect(
      () => MusicAlbum.fromJson({
        ..._albumJson(),
        'credits': [credit],
        'discs': [disc],
      }),
      throwsFormatException,
    );
  });

  test('Music credits allow an absent contributor and require instruments list',
      () {
    final album = MusicAlbum.fromJson({
      ..._albumJson(),
      'credits': [_creditJson(id: 'credit-one')],
    });
    final credit = album.credits.single;

    expect(credit.contributorId, isNull);
    expect(credit.instruments, isEmpty);
    expect(credit.toJson(), isNot(contains('contributor_id')));

    expect(
      () => MusicAlbum.fromJson({
        ..._albumJson(),
        'credits': [
          {..._creditJson(id: 'credit-two'), 'instruments': 'violin'},
        ],
      }),
      throwsFormatException,
    );
    expect(
      () => MusicAlbum.fromJson({
        ..._albumJson(),
        'credits': [
          {
            ..._creditJson(id: 'credit-three'),
            'instruments': ['violin', 7]
          },
        ],
      }),
      throwsFormatException,
    );
  });
}

Map<String, Object?> _albumJson() => {
      'title': 'Edition',
      'revision': 1,
      'release_date': {'year': 1997, 'month': 5, 'day': 21},
      'genres': <String>[],
      'extra': ['foo', 'bar'],
      'external_links': <Object?>[],
      'credits': <Object?>[],
      'artist_credits': <Object?>[],
      'discs': [
        _discJson(
          id: 'disc-one',
          number: 1,
          recordingDate: {'year': 2025, 'month': 5},
        ),
      ],
    };

Map<String, Object?> _discJson({
  required String id,
  required int number,
  Map<String, Object?>? recordingDate,
  List<Map<String, Object?>> credits = const [],
  List<Map<String, Object?>> tracks = const [],
}) =>
    {
      'id': id,
      'disc_number': number,
      'format': 'CD',
      'format_family': 'opticalDisc',
      'sound_types': <String>[],
      if (recordingDate != null) 'recording_date': recordingDate,
      'recording_locations': <String>[],
      'credits': credits,
      'tracks': tracks,
    };

Map<String, Object?> _creditJson({required String id}) => {
      'id': id,
      'name': 'A Contributor',
      'role': 'Producer',
      'instruments': <String>[],
      'sequence': 1,
    };

Map<String, Object?> _trackJson({required String id}) => {
      'id': id,
      'position': '1',
      'title': 'Track',
      'is_header': false,
      'indent_level': 0,
    };
