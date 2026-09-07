import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known metadata provider registry resolves providers by kind', () {
    expect(
      collectarrMetadataProviderRegistry
          .forKind(CatalogMediaKind.comic)
          .map((provider) => provider.id),
      ['gcd', 'comicvine'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind(CatalogMediaKind.game)
          .map((provider) => provider.id),
      ['igdb'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind(CatalogMediaKind.manga)
          .map((provider) => provider.id),
      ['mangadex', 'anilist', 'comicvine', 'hardcover'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind(CatalogMediaKind.anime)
          .map((provider) => provider.id),
      ['anilist', 'tmdb'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind(CatalogMediaKind.movie)
          .map((provider) => provider.id),
      ['tmdb'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind(CatalogMediaKind.tv)
          .map((provider) => provider.id),
      ['tmdb'],
    );
    expect(
      collectarrMetadataProviderRegistry.forKind(CatalogMediaKind.unknown),
      isEmpty,
    );
  });

  test('known metadata provider registry resolves provider details', () {
    final comicVine = collectarrMetadataProviderRegistry.byId('comicvine');

    expect(comicVine?.requiresApiKey, isTrue);
    expect(comicVine?.usagePolicy?.nonCommercialOnly, isTrue);
    expect(collectarrMetadataProviderRegistry.byId('missing'), isNull);
  });
}
