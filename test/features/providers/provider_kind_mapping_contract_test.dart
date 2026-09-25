import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/providers/library_provider_registry.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/kind_contract_manifest.dart';

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

ProviderRawEnvelope _envelopeFor(_ProviderKindCase testCase) {
  final normalized = testCase.normalizeNative();
  return ProviderRawEnvelope(
    provider: testCase.provider,
    providerItemId: testCase.providerItemId,
    kind: testCase.kind,
    payload: ProviderNormalizedPayload(normalized),
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

Object _kindMetadata(
  CatalogMediaKind kind, {
  required String title,
  required String synopsis,
  required String coverImageUrl,
  required String publisher,
}) {
  final json = {
    'title': title,
    'synopsis': synopsis,
    'cover_image_url': coverImageUrl,
    'publisher': publisher,
  };
  return switch (kind) {
    CatalogMediaKind.anime => AnimeMetadata.fromJson(json),
    CatalogMediaKind.boardgame => BoardGameMetadata.fromJson(json),
    CatalogMediaKind.book => BookCatalogMetadata.fromJson(json),
    CatalogMediaKind.comic => ComicMedia.fromJson(json),
    CatalogMediaKind.game => GameCatalogMetadata.fromJson({
        ...json,
        'publishers': [publisher],
      }),
    CatalogMediaKind.manga => MangaMetadata.fromJson(json),
    CatalogMediaKind.movie => MovieCatalogMetadata.fromJson(json),
    CatalogMediaKind.tv => TvSeriesMetadata.fromJson(json),
    CatalogMediaKind.music ||
    CatalogMediaKind.unknown =>
      throw ArgumentError.value(kind, 'kind', 'Expected a library kind'),
  };
}

CatalogSearchCandidate _candidate({
  required CatalogMediaKind kind,
  required String title,
  required String synopsis,
  required String coverImageUrl,
  required String publisher,
}) {
  final item = CatalogItemDto.raw(
    id: '${kind.apiValue}-${title.toLowerCase().replaceAll(' ', '-')}',
    mediaKind: kind,
    common: CatalogCommonDto(
      title: title,
      synopsis: synopsis,
      coverImageUrl: coverImageUrl,
    ),
    kindMetadata: _kindMetadata(
      kind,
      title: title,
      synopsis: synopsis,
      coverImageUrl: coverImageUrl,
      publisher: publisher,
    ),
  );
  return CatalogSearchCandidate.fromItem(item);
}

void main() {
  final registry = buildDefaultProviderRegistry();

  test('provider matrix covers the declared provider-kind manifest', () {
    final covered = {
      for (final testCase in _providerKindCases)
        '${testCase.provider}:${testCase.kind.apiValue}',
      'musicbrainz:${CatalogMediaKind.music.apiValue}',
    };
    final declared = {
      for (final entry in kindContractManifest.providerKindParticipants.entries)
        for (final kind in entry.value) '${entry.key}:${kind.apiValue}',
    };

    expect(covered, equals(declared));
  });

  for (final testCase in _providerKindCases) {
    test('${testCase.kind.apiValue} provider connector normalizes its kind',
        () {
      final connector = registry.get(testCase.provider);
      expect(connector, isNotNull);
      expect(connector!.descriptor.supportsKind(testCase.kind), isTrue);

      final envelope = _envelopeFor(testCase);
      expect(envelope.payload['kind'], testCase.kind.apiValue);
      expect(envelope.payload['title'], isNotEmpty);
    });
  }

  test('correction registry maps typed kind metadata into wire patches', () {
    const kinds = [
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.manga,
      CatalogMediaKind.movie,
      CatalogMediaKind.tv,
    ];

    for (final kind in kinds) {
      final buildCorrections = libraryProviderCorrectionBuildersByKind[kind]!;
      final preview = _candidate(
        kind: kind,
        title: 'Before title',
        synopsis: 'Before synopsis',
        coverImageUrl: 'https://example.test/before.jpg',
        publisher: 'Before Publisher',
      );
      final edited = _candidate(
        kind: kind,
        title: 'After title',
        synopsis: 'After synopsis',
        coverImageUrl: 'https://example.test/after.jpg',
        publisher: 'After Publisher',
      );

      final patch = buildCorrections(preview: preview, edited: edited);
      expect(patch.isEmpty, isFalse, reason: kind.apiValue);
      expect(
        providerCorrectionWireEncoderForKind(kind)(patch),
        {
          'title': 'After title',
          'synopsis': 'After synopsis',
          'cover_image_url': 'https://example.test/after.jpg',
          'publisher': 'After Publisher',
        },
        reason: kind.apiValue,
      );

      final unchanged = buildCorrections(preview: edited, edited: edited);
      expect(unchanged.isEmpty, isTrue, reason: kind.apiValue);
      expect(
        providerCorrectionWireEncoderForKind(kind)(unchanged),
        isEmpty,
        reason: kind.apiValue,
      );
    }
  });

  test('correction builders reject metadata owned by another kind', () {
    final wronglyTyped = CatalogItemDto.raw(
      id: 'wrongly-typed',
      mediaKind: CatalogMediaKind.anime,
      common: const CatalogCommonDto(title: 'Wrongly typed'),
      kindMetadata: BoardGameMetadata.fromJson(
        const {'title': 'Wrongly typed'},
      ),
    );
    final candidate = CatalogSearchCandidate.fromItem(wronglyTyped);
    final buildAnimeCorrections =
        libraryProviderCorrectionBuildersByKind[CatalogMediaKind.anime]!;

    expect(
      () => buildAnimeCorrections(preview: candidate, edited: candidate),
      throwsA(isA<StateError>()),
    );
  });

  test('provider-kind envelope fixtures remain readable', () {
    final fixtureFile =
        File('tool/core_contracts/golden-provider-envelopes.json');
    expect(fixtureFile.existsSync(), isTrue);
    final fixtures =
        jsonDecode(fixtureFile.readAsStringSync()) as List<dynamic>;
    expect(fixtures, hasLength(10));
    expect(
      fixtures.map((fixture) => (fixture as Map)['provider']),
      containsAll(
        _providerKindCases.map((testCase) => testCase.provider).toSet(),
      ),
    );
  });
}
