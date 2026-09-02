import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kind runtime projects linked metadata from typed catalog values', () {
    const metadata = ComicCatalogMetadata(
      title: 'Common Title',
      searchAliases: ['Alias'],
      seriesTitle: 'Typed Series',
      issueNumber: '7',
      publisher: 'Typed Publisher',
      variant: 'Direct',
      imprint: 'Typed Imprint',
      creators: [
        {'name': 'Typed Creator'},
      ],
      genres: ['Typed Genre'],
    );
    final candidates = libraryKindRuntimeForKind(CatalogMediaKind.comic)
        .linkedMetadata
        .candidatesForEntry(
          _shelfEntry(CatalogMediaKind.comic, metadata),
        )
        .toList();

    expect(
      candidates,
      containsAll([
        'Common Title',
        'Alias',
        'Typed Series',
        '7',
        'Typed Publisher',
        'Direct',
        'Typed Imprint',
        'Typed Creator',
        'Typed Genre',
      ]),
    );
  });

  test('typed capability ignores incompatible metadata runtimes', () {
    const capability =
        TypedLibraryLinkedMetadataCapability<ComicCatalogMetadata>(
      _comicPublisher,
    );
    final candidates = capability
        .candidatesForEntry(
          _shelfEntry(
            CatalogMediaKind.game,
            const EmptyKindMetadata(CatalogMediaKind.game),
          ),
        )
        .toList();

    expect(candidates, isEmpty);
    expect(candidates, isNot(contains('Typed Publisher')));
  });

  test('linked filter matches values projected by the kind capability', () {
    final item = LibraryProjectionItem.fromShelf(
      _shelfEntry(
        CatalogMediaKind.comic,
        const ComicCatalogMetadata(
          title: 'Typed Comic',
          publisher: 'Typed Publisher',
        ),
      ),
      comicKindModule,
    );

    expect(
      libraryEntryMatchesLinkedMetadataFilter(
        item,
        'typed publisher',
        comicKindModule,
      ),
      isTrue,
    );
    expect(
      libraryEntryMatchesLinkedMetadataFilter(
        item,
        'missing publisher',
        comicKindModule,
      ),
      isFalse,
    );
  });

  test('anime linked metadata includes studio aliases', () {
    const metadata = AnimeMetadata(
      title: 'Typed Anime',
      studios: ['Madhouse'],
      producers: ['Aniplex'],
    );
    final entry = _shelfEntry(CatalogMediaKind.anime, metadata);
    final candidates = libraryKindRuntimeForKind(CatalogMediaKind.anime)
        .linkedMetadata
        .candidatesForEntry(entry)
        .toList();

    expect(candidates, containsAll(['Madhouse', 'Aniplex']));

    final item = LibraryProjectionItem.fromShelf(entry, animeKindModule);
    expect(
      libraryEntryMatchesLinkedMetadataFilter(
        item,
        'madhouse',
        animeKindModule,
      ),
      isTrue,
    );
  });
}

Iterable<String?> _comicPublisher(ComicCatalogMetadata metadata) => [
      metadata.publisher,
    ];

ShelfEntry _shelfEntry(
  CatalogMediaKind kind,
  LibraryKindMetadataRuntime metadata,
) {
  return ShelfEntry(
    itemId: 'item-1',
    catalogItem: LibraryMetadataItem(
      identity: LibraryItemIdentity(id: 'item-1', mediaKind: kind),
      kindMetadata: metadata,
    ),
  );
}
