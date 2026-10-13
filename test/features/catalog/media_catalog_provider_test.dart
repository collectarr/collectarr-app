import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(resetMediaCatalogCacheForTesting);

  test('media catalog cache falls back when Core is unavailable', () async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(_FailingCatalogApiClient()),
      ],
    );
    addTearDown(container.dispose);

    final catalog = await container.read(mediaCatalogProvider.future);

    expect(
      catalog.map((type) => type.kind),
      ['music'],
    );
  });

  test('media catalog cache is reused for the same base url', () async {
    final api = _CatalogApiClient([
      const CatalogMediaType(
        kind: 'music',
        singularLabel: 'Movie',
        pluralLabel: 'Movies',
        routeSegments: ['movies'],
      ),
    ]);
    final first = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(api)],
    );
    addTearDown(first.dispose);

    expect(await first.read(mediaCatalogProvider.future), hasLength(1));
    expect(api.calls, 1);

    final second = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(_FailingCatalogApiClient()),
      ],
    );
    addTearDown(second.dispose);

    final cached = await second.read(mediaCatalogProvider.future);

    expect(cached.single.kind, 'music');
  });

  test('physical formats can be read from Core catalog', () async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(
          _CatalogApiClient([
            const CatalogMediaType(
              kind: 'music',
              singularLabel: 'Movie',
              pluralLabel: 'Movies',
              routeSegments: ['movies'],
              physicalFormats: [
                CatalogPhysicalFormat(
                  id: 'hd-dvd',
                  label: 'HD DVD',
                  mediaFamily: 'video',
                  variantType: 'physical',
                  aliases: ['hddvd'],
                ),
              ],
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final catalog = await container.read(mediaCatalogProvider.future);
    final formats = physicalMediaFormatsForKind(
      catalog,
      CatalogMediaKind.music,
    );

    final format = formats.singleWhere((format) => format.id == 'hd-dvd');
    expect(format.aliases, {'hddvd'});
  });

  test('media catalog provider normalizes known display labels', () async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(
          _CatalogApiClient([
            const CatalogMediaType(
              kind: 'music',
              singularLabel: 'Album',
              pluralLabel: 'Albums',
              routeSegments: ['music'],
            ),
            const CatalogMediaType(
              kind: 'movie',
              singularLabel: 'Film',
              pluralLabel: 'Films',
              routeSegments: ['movies'],
            ),
            const CatalogMediaType(
              kind: 'boardgame',
              singularLabel: 'Boardgame',
              pluralLabel: 'Boardgame',
              routeSegments: ['boardgames'],
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final catalog = await container.read(mediaCatalogProvider.future);

    expect(
      catalog
          .firstWhere((type) => _isKind(type, CatalogMediaKind.music))
          .singularLabel,
      'Album',
    );
    expect(catalog, hasLength(1));
  });

  test('physical format fallbacks use catalog kind defaults', () {
    expect(
      physicalMediaFormatsForKind(
        const [],
        CatalogMediaKind.music,
      ).map((format) => format.id),
      containsAll(['vinyl', 'cd', 'cassette']),
    );
    expect(
      physicalMediaFormatsForKind(const [], CatalogMediaKind.unknown),
      isEmpty,
    );
  });
}

bool _isKind(CatalogMediaType type, CatalogMediaKind kind) {
  return catalogMediaKindFromApiValue(type.kind) == kind;
}

class _CatalogApiClient extends ApiClient {
  _CatalogApiClient(this.catalogMediaTypes)
      : super(baseUrl: 'http://core.local');

  final List<CatalogMediaType> catalogMediaTypes;
  int calls = 0;

  @override
  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    calls += 1;
    return catalogMediaTypes;
  }
}

class _FailingCatalogApiClient extends ApiClient {
  _FailingCatalogApiClient() : super(baseUrl: 'http://core.local');

  @override
  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    throw StateError('Core unavailable');
  }
}
