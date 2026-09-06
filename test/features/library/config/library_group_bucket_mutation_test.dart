import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/library_group_bucket_mutation.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

CatalogItem _metadata(
  String kind,
  Map<String, dynamic> payload,
) {
  return testCatalogItemWithKindMetadata(
    testCatalogItem(
      id: '$kind-1',
      kind: kind,
      title: 'Test item',
      payload: payload,
    ),
  );
}

CatalogItem _mutateGroup(
  CatalogItem item,
  CatalogMediaKind kind,
  String mode,
  String currentLabel, {
  String? replacement,
}) {
  final runtime = libraryKindModuleForKind(kind);
  final definition = runtime.fields.findGroupDefinition(
    runtime.fields.decodeGroupId(mode),
  );
  expect(definition, isNotNull);
  final updated = definition!.bucketValueMutator?.call(
    item,
    currentLabel,
    replacement: replacement,
  );
  expect(updated, isNotNull);
  return updated!;
}

void main() {
  test('updates scalar and nested publishing aliases', () {
    final item = _metadata(
      'book',
      {
        'publisher': 'Old publisher',
        'original_publisher': 'Old publisher',
        'publishing': {
          'original_publisher': 'Old publisher',
          'imprint': 'Old imprint',
        },
      },
    );

    final updated = _mutateGroup(
      item,
      CatalogMediaKind.book,
      'book.publisher',
      'Old publisher',
      replacement: 'New publisher',
    );

    expect(updated.payload['publisher'], 'New publisher');
    expect(updated.payload['original_publisher'], 'New publisher');
    final publishing = updated.payload['publishing'] as Map;
    expect(publishing['original_publisher'], 'New publisher');
    expect(publishing['imprint'], 'Old imprint');
  });

  test('updates movie publisher and studio aliases', () {
    final updated = _mutateGroup(
      _metadata(
        'movie',
        {
          'publisher': 'Old studio',
          'studio': 'Old studio',
        },
      ),
      CatalogMediaKind.movie,
      'movie.publisher',
      'Old studio',
      replacement: 'New studio',
    );

    expect(updated.payload['publisher'], 'New studio');
    expect(updated.payload['studio'], 'New studio');
  });

  test('replaces one genre without duplicating a case-insensitive value', () {
    final updated = _mutateGroup(
      _metadata(
        'movie',
        {
          'genres': ['Action', 'Drama'],
        },
      ),
      CatalogMediaKind.movie,
      'movie.genre',
      'Action',
      replacement: 'drama',
    );

    expect(updated.payload['genres'], ['drama']);
  });

  test('replaces a joined list bucket as one value', () {
    final updated = _mutateGroup(
      _metadata(
        'movie',
        {
          'genres': ['Action', 'Drama'],
        },
      ),
      CatalogMediaKind.movie,
      'movie.genre',
      'Action, Drama',
      replacement: 'Adventure',
    );

    expect(updated.payload['genres'], ['Adventure']);
  });

  test('preserves an explicit scalar alias when a list supplies the bucket',
      () {
    final item = _metadata(
      'anime',
      {
        'studios': ['Old studio'],
        'publisher': 'Explicit publisher',
      },
    );
    final updated = libraryStringListBucketValueMutator(
      'studios',
      scalarMirrorKeys: ['publisher'],
    )(
      item,
      'Old studio',
      replacement: 'New studio',
    );

    expect(updated, isNotNull);
    expect(updated!.payload['studios'], ['New studio']);
    expect(updated.payload['publisher'], 'Explicit publisher');
  });

  test('updates a matching scalar alias with a list bucket', () {
    final item = _metadata(
      'anime',
      {
        'studios': ['Old studio'],
        'publisher': 'Old studio',
      },
    );
    final updated = libraryStringListBucketValueMutator(
      'studios',
      scalarMirrorKeys: ['publisher'],
    )(
      item,
      'Old studio',
      replacement: 'New studio',
    );

    expect(updated, isNotNull);
    expect(updated!.payload['studios'], ['New studio']);
    expect(updated.payload['publisher'], 'New studio');
  });

  test('returns no update when the current label does not match', () {
    final item = _metadata(
      'music',
      {
        'artist': 'Artist',
      },
    );

    final updated = libraryStringBucketValueMutator('artist')(
      item,
      'Different artist',
      replacement: 'New artist',
    );

    expect(updated, isNull);
  });

  test('builds an owned condition update and clears empty replacements', () {
    final item = testOwnedItem(
      id: 'owned-music-1',
      itemId: 'music-1',
      kind: 'music',
      condition: 'Very Good',
    );
    final mutator = libraryOwnedConditionBucketValueMutator();

    final update = mutator(item, 'Very Good', replacement: 'Mint');
    expect(update, isNotNull);
    expect(update!.ownedItemId, 'owned-music-1');
    expect(update.condition, isA<SetValue<String?>>());
    expect((update.condition as SetValue<String?>).value, 'Mint');

    final clear = mutator(item, 'Very Good', replacement: '   ');
    expect(clear, isNotNull);
    expect(clear!.condition, isA<ClearValue<String?>>());
  });
}
