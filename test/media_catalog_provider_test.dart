import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(resetMediaCatalogCacheForTesting);

  test('media catalog provider falls back when Core is unavailable', () async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(_FailingCatalogApiClient()),
      ],
    );
    addTearDown(container.dispose);

    final catalog = await container.read(mediaCatalogProvider.future);

    expect(catalog.map((type) => type.kind), containsAll(['comic', 'manga']));
    expect(
      catalog.firstWhere((type) => type.kind == 'manga').providers,
      ['anilist', 'comicvine'],
    );
  });

  test('resolved library type uses Core provider defaults', () async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(
          _CatalogApiClient([
            const CatalogMediaType(
              kind: 'comic',
              singularLabel: 'Comic issue',
              pluralLabel: 'Comic issues',
              routeSegments: ['comics'],
              defaultProvider: 'comicvine',
              providers: ['comicvine', 'gcd'],
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(mediaCatalogProvider.future);
    final type = container.read(
      resolvedLibraryTypeProvider(comicsLibraryConfig),
    );

    expect(type.singularLabel, 'Comic issue');
    expect(type.pluralLabel, 'Comic issues');
    expect(type.defaultMetadataProvider, 'comicvine');
    expect(type.supportedMetadataProviders.map((provider) => provider.id), [
      'comicvine',
      'gcd',
    ]);
  });

  test('media catalog cache is reused for the same base url', () async {
    final api = _CatalogApiClient([
      const CatalogMediaType(
        kind: 'movie',
        singularLabel: 'Movie',
        pluralLabel: 'Movies',
        routeSegments: ['movies'],
        defaultProvider: 'tmdb',
        providers: ['tmdb'],
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

    expect(cached.single.kind, 'movie');
  });

  test('physical formats can be read from Core catalog', () async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(
          _CatalogApiClient([
            const CatalogMediaType(
              kind: 'movie',
              singularLabel: 'Movie',
              pluralLabel: 'Movies',
              routeSegments: ['movies'],
              defaultProvider: 'tmdb',
              providers: ['tmdb'],
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

    await container.read(mediaCatalogProvider.future);
    final formats = container.read(videoPhysicalMediaFormatsProvider);

    expect(formats.single.id, 'hd-dvd');
    expect(formats.single.aliases, {'hddvd'});
  });
}

class _CatalogApiClient extends ApiClient {
  _CatalogApiClient(this.catalog) : super(baseUrl: 'http://core.local');

  final List<CatalogMediaType> catalog;
  int calls = 0;

  @override
  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    calls += 1;
    return catalog;
  }
}

class _FailingCatalogApiClient extends ApiClient {
  _FailingCatalogApiClient() : super(baseUrl: 'http://core.local');

  @override
  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    throw StateError('Core unavailable');
  }
}
