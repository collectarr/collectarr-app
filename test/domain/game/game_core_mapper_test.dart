import 'dart:io';

import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/game/data/remote/game_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/data/remote/game_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/core_field_adoption_contract.dart';
import '../../contracts/core_mapping_contract.dart';

void main() {
  test('GameWorkDto maps directly into GameMedia and typed releases', () {
    final dto = GameWorkDto.fromJson({
      'id': 'game-1',
      'kind': 'game',
      'title': 'Chrono Trigger',
      'platforms': ['SNES', 'Nintendo DS'],
      'identifiers': ['igdb:game-1'],
      'company_roles': ['developer', 'publisher'],
      'age_ratings': ['E10+'],
      'genres': ['Role-playing'],
      'search_aliases': ['Chrono'],
      'original_language': 'ja',
      'publisher': 'Square',
      'release_date': '1995-03-11T00:00:00Z',
      'sort_title': 'Chrono Trigger',
      'subtitle': 'Time travel adventure',
      'description': 'A party travels through time.',
      'cover_image_url': 'https://example.com/chrono.jpg',
      'releases': [
        {
          'id': 'release-1',
          'work_id': 'game-1',
          'release_title': 'SNES Cartridge',
          'platform': 'SNES',
          'release_date': '1995-03-11T00:00:00Z',
          'region_code': 'US',
          'format': 'cartridge',
          'publisher': 'Square',
          'catalog_number': 'SNS-CT-USA',
          'release_status': 'released',
          'language': 'en',
          'barcode': '123456789',
          'cover_image_url': 'https://example.com/release.jpg',
        },
      ],
    });

    final media = GameCoreMapper.fromWorkDto(dto);

    expect(media.id, const GameMediaId('game-1'));
    expect(media.title, 'Chrono Trigger');
    expect(media.platforms, ['SNES', 'Nintendo DS']);
    expect(media.identifiers, ['igdb:game-1']);
    expect(media.companyRoles, ['developer', 'publisher']);
    expect(media.ageRatings, ['E10+']);
    expect(media.publisher, 'Square');
    expect(media.releaseDate, DateTime.utc(1995, 3, 11));
    expect(media.coverImageUrl, 'https://example.com/chrono.jpg');
    expect(media.releases, hasLength(1));
    expect(media.releases.single.typedId, const GameReleaseId('release-1'));
    expect(media.releases.single.workId, 'game-1');
    expect(media.releases.single.title, 'SNES Cartridge');
    expect(media.releases.single.regionCode, 'US');
    expect(media.releases.single.barcode, '123456789');
  });

  test('GameReleaseDto maps independently from GameWorkDto', () {
    final dto = GameReleaseDto.fromJson({
      'id': 'release-2',
      'kind': 'game',
      'work_id': 'game-2',
      'release_title': 'PC Big Box',
      'platform': 'PC',
      'region_code': 'EU',
      'format': 'big-box',
      'release_status': 'released',
      'language': 'en',
    });

    final release = GameCoreMapper.fromReleaseDto(dto);

    expect(release.typedId, const GameReleaseId('release-2'));
    expect(release.workId, 'game-2');
    expect(release.title, 'PC Big Box');
    expect(release.platform, 'PC');
    expect(release.regionCode, 'EU');
    expect(release.format, 'big-box');
  });

  test('Game mapper rejects a DTO with the wrong kind', () {
    final dto = GameWorkDto.fromJson({
      'id': 'not-game',
      'kind': 'book',
      'title': 'Wrong kind',
    });

    expect(
      () => GameCoreMapper.fromWorkDto(dto),
      throwsA(isA<StateError>()),
    );
  });

  test('Game remote source maps work and release fetches separately', () async {
    final source = ApiGameRemoteSource(
      (id) async {
        expect(id, 'game-2');
        return GameWorkDto.fromJson({
          'id': id,
          'kind': 'game',
          'title': 'The Secret of Monkey Island',
        });
      },
      (id) async {
        expect(id, 'release-3');
        return GameReleaseDto.fromJson({
          'id': id,
          'kind': 'game',
          'work_id': 'game-2',
          'release_title': 'Amiga Release',
        });
      },
    );

    final media = await source.fetchMedia(const GameMediaId('game-2'));
    final release = await source.fetchRelease(const GameReleaseId('release-3'));

    expect(media.id, const GameMediaId('game-2'));
    expect(media.title, 'The Secret of Monkey Island');
    expect(release.typedId, const GameReleaseId('release-3'));
    expect(release.workId, 'game-2');
  });

  defineCoreMappingContract<GameMedia, GameWorkDto>(
    name: 'game',
    createDomain: () => GameMedia(
      id: const GameMediaId('game-contract'),
      title: 'Contract Game',
      sortTitle: 'Contract Game',
      description: 'Contract description',
      releaseDate: DateTime.utc(2020, 1, 2),
      originalLanguage: 'en',
      publisher: 'Contract Publisher',
      subtitle: 'Contract subtitle',
      platforms: const ['PC'],
      identifiers: const ['contract-id'],
      companyRoles: const ['developer'],
      ageRatings: const ['E'],
      genres: const ['Adventure'],
      searchAliases: const ['Contract'],
      releases: const [
        GameRelease(
          id: 'release-contract',
          workId: 'game-contract',
          title: 'Contract Release',
          platform: 'PC',
        ),
      ],
    ),
    encode: (domain) => GameWorkDto.fromJson(domain.toJson()),
    decode: GameCoreMapper.fromWorkDto,
    equals: (left, right) =>
        left.id == right.id &&
        left.title == right.title &&
        left.sortTitle == right.sortTitle &&
        left.description == right.description &&
        left.releaseDate == right.releaseDate &&
        left.originalLanguage == right.originalLanguage &&
        left.publisher == right.publisher &&
        left.subtitle == right.subtitle &&
        left.platforms.length == right.platforms.length &&
        left.identifiers.length == right.identifiers.length &&
        left.companyRoles.length == right.companyRoles.length &&
        left.ageRatings.length == right.ageRatings.length &&
        left.genres.length == right.genres.length &&
        left.searchAliases.length == right.searchAliases.length &&
        left.releases.length == right.releases.length,
  );

  test('GameWorkDto fields are explicitly classified', () {
    final source = File(
      'lib/core/api/generated/collectarr_api.models.dart',
    ).readAsStringSync();
    validateCoreDtoFieldAdoption(
      source: source,
      policy: CoreFieldAdoptionPolicy(
        dtoName: 'GameWorkDto',
        mapped: {
          'id',
          'title',
          'platforms',
          'identifiers',
          'companyRoles',
          'ageRatings',
          'genres',
          'searchAliases',
          'releases',
          'originalLanguage',
          'publisher',
          'releaseDateValue',
          'sortTitle',
          'subtitle',
          'description',
        },
        intentionallyIgnored: {
          'kind': 'used to validate the typed Game DTO boundary',
        },
      ),
    );
  });

  test('GameReleaseDto fields are explicitly classified', () {
    final source = File(
      'lib/core/api/generated/collectarr_api.models.dart',
    ).readAsStringSync();
    validateCoreDtoFieldAdoption(
      source: source,
      policy: CoreFieldAdoptionPolicy(
        dtoName: 'GameReleaseDto',
        mapped: {
          'id',
          'workId',
          'releaseTitle',
          'platform',
          'releaseDateValue',
          'regionCode',
          'format',
          'publisher',
          'catalogNumber',
          'releaseStatus',
          'language',
          'barcodeValue',
          'coverImageUrlValue',
        },
        intentionallyIgnored: {},
      ),
    );
  });
}
