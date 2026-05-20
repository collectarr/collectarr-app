import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known metadata provider registry resolves providers by kind', () {
    expect(
      collectarrMetadataProviderRegistry
          .forKind('comic')
          .map((provider) => provider.id),
      ['gcd', 'comicvine'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind('game')
          .map((provider) => provider.id),
      ['igdb'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind('manga')
          .map((provider) => provider.id),
      ['mangadex', 'anilist', 'comicvine'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind('anime')
          .map((provider) => provider.id),
      ['anilist', 'tmdb'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind('movie')
          .map((provider) => provider.id),
      ['tmdb'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind('tv')
          .map((provider) => provider.id),
      ['tmdb'],
    );
    expect(collectarrMetadataProviderRegistry.forKind('bluray'), isEmpty);
  });

  test('known metadata provider registry resolves provider details', () {
    final comicVine = collectarrMetadataProviderRegistry.byId('comicvine');

    expect(comicVine?.requiresApiKey, isTrue);
    expect(comicVine?.usagePolicy?.nonCommercialOnly, isTrue);
    expect(collectarrMetadataProviderRegistry.byId('missing'), isNull);
  });
}
