import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/models/library_common_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kind runtime projects linked metadata from typed catalog values', () {
    const metadata = ComicCatalogMetadata(
      title: 'Typed Comic',
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

    expect(candidates, containsAll(['Common Title', 'Alias']));
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
      comicsLibraryConfig,
    );

    expect(
      libraryEntryMatchesLinkedMetadataFilter(
        item,
        'typed publisher',
        comicsLibraryConfig,
      ),
      isTrue,
    );
    expect(
      libraryEntryMatchesLinkedMetadataFilter(
        item,
        'missing publisher',
        comicsLibraryConfig,
      ),
      isFalse,
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
      common: const LibraryCommonMetadata(
        title: 'Common Title',
        searchAliases: ['Alias'],
      ),
      kindMetadata: metadata,
    ),
  );
}
