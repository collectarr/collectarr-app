import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

class _ProviderKindCase {
  const _ProviderKindCase({
    required this.provider,
    required this.kind,
    required this.providerItemId,
    required this.normalizeNative,
  });

  final String provider;
  final CatalogMediaKind kind;
  final String providerItemId;
  final Map<String, dynamic> Function() normalizeNative;
}

final _providerKindCases = <_ProviderKindCase>[
  _ProviderKindCase(
    provider: 'anilist',
    kind: CatalogMediaKind.anime,
    providerItemId: 'anime-154587',
    normalizeNative: () => AniListProvider().normalize({
      'id': 154587,
      'type': 'ANIME',
      'title': {'romaji': 'Contract Anime'},
      'description': 'A contract anime payload.',
      'coverImage': {'large': 'https://example.test/anime.jpg'},
    }),
  ),
  _ProviderKindCase(
    provider: 'anilist',
    kind: CatalogMediaKind.manga,
    providerItemId: 'manga-30002',
    normalizeNative: () => AniListProvider().normalize({
      'id': 30002,
      'type': 'MANGA',
      'title': {'romaji': 'Contract Manga'},
      'description': 'A contract manga payload.',
      'coverImage': {'large': 'https://example.test/manga.jpg'},
    }),
  ),
  _ProviderKindCase(
    provider: 'bgg',
    kind: CatalogMediaKind.boardgame,
    providerItemId: 'bgg-174430',
    normalizeNative: () => BGGProvider().normalize({
      'id': '174430',
      'type': 'boardgame',
      'names': [
        {'type': 'primary', 'value': 'Contract Board Game'},
      ],
      'description': 'A contract board game payload.',
    }),
  ),
  _ProviderKindCase(
    provider: 'comicvine',
    kind: CatalogMediaKind.comic,
    providerItemId: '4000-160294',
    normalizeNative: () => ComicVineProvider().normalize({
      'id': '4000-160294',
      'media_type': 'comic',
      'name': 'Contract Comic',
      'issue_number': '1',
      'volume': {'name': 'Contract Series'},
    }),
  ),
  _ProviderKindCase(
    provider: 'comicvine',
    kind: CatalogMediaKind.manga,
    providerItemId: '4000-160295',
    normalizeNative: () => ComicVineProvider().normalize({
      'id': '4000-160295',
      'media_type': 'manga',
      'name': 'Contract Manga',
      'issue_number': '1',
      'volume': {'name': 'Contract Manga Series'},
    }),
  ),
  _ProviderKindCase(
    provider: 'gcd',
    kind: CatalogMediaKind.comic,
    providerItemId: 'gcd-12345',
    normalizeNative: () => GCDProvider().normalize({
      'id': '12345',
      'series_name': 'Contract Comic',
      'number': '300',
    }),
  ),
  _ProviderKindCase(
    provider: 'hardcover',
    kind: CatalogMediaKind.book,
    providerItemId: 'hardcover-1234',
    normalizeNative: () => HardcoverProvider().normalize({
      'id': 1234,
      'title': 'Contract Book',
      '_collectarr_kind': 'book',
    }),
  ),
  _ProviderKindCase(
    provider: 'hardcover',
    kind: CatalogMediaKind.manga,
    providerItemId: 'hardcover-manga-1234',
    normalizeNative: () => HardcoverProvider().normalize({
      'id': 1234,
      'title': 'Contract Hardcover Manga',
      '_collectarr_kind': 'manga',
    }),
  ),
  _ProviderKindCase(
    provider: 'igdb',
    kind: CatalogMediaKind.game,
    providerItemId: 'igdb-1942',
    normalizeNative: () => IGDBProvider().normalize({
      'id': 1942,
      'name': 'Contract Game',
      'summary': 'A contract game payload.',
    }),
  ),
  _ProviderKindCase(
    provider: 'mangadex',
    kind: CatalogMediaKind.manga,
    providerItemId: 'mangadex-d7037b2a',
    normalizeNative: () => MangaDexProvider().normalize({
      'id': 'd7037b2a-874a-4360-8a7b-07f2001542a9',
      'attributes': {
        'title': {'en': 'Contract MangaDex Manga'},
        'description': {'en': 'A contract MangaDex payload.'},
      },
    }),
  ),
  _ProviderKindCase(
    provider: 'musicbrainz',
    kind: CatalogMediaKind.music,
    providerItemId: 'musicbrainz-a1b2c3d4',
    normalizeNative: () => MusicBrainzProvider().normalize({
      'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
      'title': 'Contract Music Release',
      'artist-credit': [
        {
          'name': 'Contract Artist',
          'artist': {'name': 'Contract Artist'},
        },
      ],
    }),
  ),
  _ProviderKindCase(
    provider: 'openlibrary',
    kind: CatalogMediaKind.book,
    providerItemId: 'openlibrary-OL27479W',
    normalizeNative: () => OpenLibraryProvider().normalize(
      workRaw: {
        'key': '/works/OL27479W',
        'title': 'Contract Open Library Book',
      },
      editionRaw: {
        'key': '/books/OL82563M',
        'title': 'Contract Open Library Book',
      },
    ),
  ),
  _ProviderKindCase(
    provider: 'tmdb',
    kind: CatalogMediaKind.anime,
    providerItemId: 'tmdb-anime-100',
    normalizeNative: () => TMDbProvider().normalize({
      'id': 100,
      'media_type': 'anime',
      'name': 'Contract TMDb Anime',
    }),
  ),
  _ProviderKindCase(
    provider: 'tmdb',
    kind: CatalogMediaKind.movie,
    providerItemId: 'tmdb-movie-550',
    normalizeNative: () => TMDbProvider().normalize({
      'id': 550,
      'media_type': 'movie',
      'title': 'Contract TMDb Movie',
    }),
  ),
  _ProviderKindCase(
    provider: 'tmdb',
    kind: CatalogMediaKind.tv,
    providerItemId: 'tmdb-tv-1399',
    normalizeNative: () => TMDbProvider().normalize({
      'id': 1399,
      'media_type': 'tv',
      'name': 'Contract TMDb TV',
    }),
  ),
];

NormalizedProviderEnvelopeV1 _envelopeFor(_ProviderKindCase testCase) {
  final normalized = testCase.normalizeNative();
  return NormalizedProviderEnvelopeV1(
    provider: testCase.provider,
    providerItemId: testCase.providerItemId,
    kind: testCase.kind.apiValue,
    normalized: normalized,
    provenance: const ProviderProvenance(fetchedAt: '2026-09-05T00:00:00Z'),
    images: [
      ProviderImageRef(
        provider: testCase.provider,
        url: 'https://example.test/${testCase.kind.apiValue}.jpg',
      ),
    ],
    attribution: const ProviderAttribution(required: false),
  );
}

void main() {
  final registry = buildDefaultProviderRegistry();

  for (final testCase in _providerKindCases) {
    test('${testCase.kind.apiValue} × ${testCase.provider} mapping contract',
        () {
      final connector = registry.get(testCase.provider);
      expect(connector, isNotNull);
      expect(
        connector!.descriptor.supportsKind(testCase.kind.apiValue),
        isTrue,
      );

      final envelope = _envelopeFor(testCase);
      expect(envelope.normalized['kind'], testCase.kind.apiValue);

      final runtime = libraryKindFor(testCase.kind);
      final mapper = runtime.providerMapper;
      expect(mapper, isNotNull);

      final item = mapper!.metadataItemFromEnvelope(envelope);
      expect(item.mediaKind, testCase.kind);
      expect(item.id, testCase.providerItemId);
      expect(item.title.trim(), isNotEmpty);
      expect(item.kindMetadata, isNot(isA<Map>()));
      expect(item.kindMetadata, isNot(isA<NormalizedProviderEnvelopeV1>()));

      final typedMapper = mapper as TypedLibraryKindProviderMapper<dynamic>;
      final catalog = typedMapper.catalogFromEnvelope(envelope);
      expect(catalog, isNotNull);
      expect(catalog, isNot(isA<Map>()));
    });
  }

  test('every registered kind mapper rejects a mismatched envelope kind', () {
    for (final runtime in collectarrKindModules) {
      final wrongKind = runtime.kind == CatalogMediaKind.book
          ? CatalogMediaKind.movie
          : CatalogMediaKind.book;
      final envelope = NormalizedProviderEnvelopeV1(
        provider: 'contract-test',
        providerItemId: 'wrong-kind',
        kind: wrongKind.apiValue,
        normalized: const {'title': 'Wrong kind'},
        provenance: const ProviderProvenance(fetchedAt: '2026-09-05T00:00:00Z'),
        images: const [],
        attribution: const ProviderAttribution(required: false),
      );
      final mapper = runtime.providerMapper!;

      expect(
        () => mapper.metadataItemFromEnvelope(envelope),
        throwsA(isA<StateError>()),
        reason: '${runtime.kind.apiValue} must validate its input kind',
      );
      final typedMapper = mapper as TypedLibraryKindProviderMapper<dynamic>;
      expect(
        () => typedMapper.catalogFromEnvelope(envelope),
        throwsA(isA<StateError>()),
      );
    }
  });

  test('provider-kind contract fixture remains readable by the test harness',
      () {
    final fixtureFile =
        File('tool/core_contracts/golden-provider-envelopes.json');
    expect(fixtureFile.existsSync(), isTrue);
    final fixtures =
        jsonDecode(fixtureFile.readAsStringSync()) as List<dynamic>;
    expect(fixtures, hasLength(10));
    expect(
      fixtures.map((fixture) => (fixture as Map)['provider']),
      containsAll(
          _providerKindCases.map((testCase) => testCase.provider).toSet()),
    );
  });
}
