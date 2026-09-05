import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import 'kind_contract_manifest.dart';

void main() {
  test('manifest lists exactly the active catalog kinds', () {
    final enumKinds =
        CatalogMediaKind.values.where((kind) => !kind.isUnknown).toSet();

    expect(kindContractManifest.activeKinds, equals(enumKinds));
    expect(kindContractManifest.activeKinds, hasLength(9));
  });

  test('every mandatory contract includes every active kind', () {
    const expectedMandatory = {
      'coreFieldAdoption',
      'coreMapping',
      'repository',
      'mediaPersistence',
      'workspace',
      'fields',
      'sort',
      'group',
      'facet',
      'vocabulary',
      'add',
      'mediaEdit',
      'identity',
      'owned',
    };

    expect(
      kindContractManifest.mandatoryParticipants.keys.toSet(),
      equals(expectedMandatory),
    );
    for (final entry in kindContractManifest.mandatoryParticipants.entries) {
      expect(
        entry.value,
        equals(kindContractManifest.activeKinds),
        reason: '${entry.key} must include every active kind',
      );
    }
  });

  test('optional contracts declare only known kind participants', () {
    const expectedOptional = {
      'release',
      'releaseRepository',
      'releaseProjection',
      'releaseEdit',
      'releasePersistence',
      'tracking',
      'hierarchy',
      'providerIntegration',
    };

    expect(
      kindContractManifest.optionalParticipants.keys.toSet(),
      equals(expectedOptional),
    );
    for (final entry in kindContractManifest.optionalParticipants.entries) {
      expect(
        kindContractManifest.activeKinds.containsAll(entry.value),
        isTrue,
        reason: '${entry.key} contains an unknown kind',
      );
    }
  });

  test('provider manifest declares every mapped provider-kind pair', () {
    const expected = {
      'anilist': {
        CatalogMediaKind.anime,
        CatalogMediaKind.manga,
      },
      'bgg': {CatalogMediaKind.boardgame},
      'comicvine': {
        CatalogMediaKind.comic,
        CatalogMediaKind.manga,
      },
      'gcd': {CatalogMediaKind.comic},
      'hardcover': {
        CatalogMediaKind.book,
        CatalogMediaKind.manga,
      },
      'igdb': {CatalogMediaKind.game},
      'mangadex': {CatalogMediaKind.manga},
      'musicbrainz': {CatalogMediaKind.music},
      'openlibrary': {CatalogMediaKind.book},
      'tmdb': {
        CatalogMediaKind.anime,
        CatalogMediaKind.movie,
        CatalogMediaKind.tv,
      },
    };

    expect(kindContractManifest.providerKindParticipants, equals(expected));
  });

  test('release manifest names every typed release participant', () {
    const releaseKinds = {
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
      CatalogMediaKind.tv,
    };
    const videoReleaseKinds = {
      CatalogMediaKind.anime,
      CatalogMediaKind.movie,
      CatalogMediaKind.tv,
    };

    expect(
      kindContractManifest.optionalParticipants['release'],
      equals(releaseKinds),
    );
    expect(
      kindContractManifest.optionalParticipants['releaseRepository'],
      equals(releaseKinds),
    );
    expect(
      kindContractManifest.optionalParticipants['releasePersistence'],
      equals(releaseKinds),
    );
    expect(
      kindContractManifest.optionalParticipants['releaseEdit'],
      equals(releaseKinds),
    );
    expect(
      kindContractManifest.optionalParticipants['releaseProjection'],
      equals(videoReleaseKinds),
    );
    expect(
      kindContractManifest.optionalParticipants['tracking'],
      equals(kindContractManifest.activeKinds),
    );
  });
}
