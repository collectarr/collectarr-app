import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/library/config/library_group_bucket_mutation.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

LibraryAddCatalogTransport _metadata(
  String kind,
  Map<String, dynamic> payload,
) {
  return LibraryAddCatalogTransport.fromItem(
    testCatalogItemWithKindMetadata(
      testCatalogItem(
        id: '$kind-1',
        kind: kind,
        title: 'Test item',
        payload: payload,
      ),
    ),
  );
}

LibraryAddCatalogTransport _mutateGroup(
  LibraryAddCatalogTransport item,
  CatalogMediaKind kind,
  String mode,
  String currentLabel, {
  String? replacement,
}) {
  final runtime = libraryKindModuleForKind(kind);
  final fields = libraryKindWorkspaceForKind(runtime.kind).fields;
  final definition = fields.findGroupDefinition(
    fields.decodeGroupId(mode),
  );
  expect(definition, isNotNull);
  final updated = definition!.bucketValueMutator?.call(
    LibraryWorkspaceSource(itemId: item.id, catalogTransport: item),
    currentLabel,
    replacement: replacement,
  );
  expect(updated, isNotNull);
  return LibraryAddCatalogTransport.fromItem(updated!.toTransportItem());
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

    final payload = updated.toTransportItem().payload;
    expect(payload['publisher'], 'New publisher');
    expect(payload['original_publisher'], 'New publisher');
    final publishing = payload['publishing'] as Map;
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

    final payload = updated.toTransportItem().payload;
    expect(payload['publisher'], 'New studio');
    expect(payload['studio'], 'New studio');
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

    expect(updated.toTransportItem().payload['genres'], ['drama']);
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

    expect(updated.toTransportItem().payload['genres'], ['Adventure']);
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
    final updated = libraryCatalogStringListBucketValueMutator(
      'studios',
      scalarMirrorKeys: ['publisher'],
    )(
      LibraryWorkspaceSource(itemId: item.id, catalogTransport: item),
      'Old studio',
      replacement: 'New studio',
    );

    expect(updated, isNotNull);
    final updatedItem = LibraryAddCatalogTransport.fromItem(
      updated!.toTransportItem(),
    );
    final payload = updatedItem.toTransportItem().payload;
    expect(payload['studios'], ['New studio']);
    expect(payload['publisher'], 'Explicit publisher');
  });

  test('updates a matching scalar alias with a list bucket', () {
    final item = _metadata(
      'anime',
      {
        'studios': ['Old studio'],
        'publisher': 'Old studio',
      },
    );
    final updated = libraryCatalogStringListBucketValueMutator(
      'studios',
      scalarMirrorKeys: ['publisher'],
    )(
      LibraryWorkspaceSource(itemId: item.id, catalogTransport: item),
      'Old studio',
      replacement: 'New studio',
    );

    expect(updated, isNotNull);
    final updatedItem = LibraryAddCatalogTransport.fromItem(
      updated!.toTransportItem(),
    );
    final payload = updatedItem.toTransportItem().payload;
    expect(payload['studios'], ['New studio']);
    expect(payload['publisher'], 'New studio');
  });

  test('returns no update when the current label does not match', () {
    final item = _metadata(
      'music',
      {
        'artist': 'Artist',
      },
    );

    final updated = libraryCatalogStringBucketValueMutator(['artist'])(
      LibraryWorkspaceSource(itemId: item.id, catalogTransport: item),
      'Different artist',
      replacement: 'New artist',
    );

    expect(updated, isNull);
  });

  test('builds an owned condition update and clears empty replacements', () {
    final item = testMusicOwnedItemFrom(
      testOwnedItem(
        id: 'owned-music-1',
        itemId: 'music-1',
        kind: 'music',
        condition: 'Very Good',
      ),
    );
    final mutator = musicOwnedConditionBucketValueMutator();

    final update = mutator(item, 'Very Good', replacement: 'Mint');
    expect(update, isNotNull);
    expect(update!.ownedRef.id.value, 'owned-music-1');
    final payload = update!.payload as MusicOwnedItemUpdatePayload;
    expect(payload.condition, isA<SetValue<String?>>());
    expect((payload.condition as SetValue<String?>).value, 'Mint');

    final clear = mutator(item, 'Very Good', replacement: '   ');
    expect(clear, isNotNull);
    final clearPayload = clear!.payload as MusicOwnedItemUpdatePayload;
    expect(clearPayload.condition, isA<ClearValue<String?>>());
  });
}
