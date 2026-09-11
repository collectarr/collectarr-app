import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('kind runtime projects linked metadata from typed catalog values', () {
    const metadata = ComicMedia(
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
    final candidates = libraryKindModuleForKind(CatalogMediaKind.comic)
        .linkedMetadata
        .candidatesForEntry(
          _shelfEntry(
            CatalogMediaKind.comic,
            metadata,
            title: 'Common Title',
          ),
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

  test('typed capability ignores invalid metadata runtimes', () {
    const capability = TypedLibraryLinkedMetadataCapability<ComicMedia>(
      _comicMetadataReader,
      _comicPublisher,
    );
    final candidates = capability
        .candidatesForEntry(
          _shelfEntry(
            CatalogMediaKind.game,
            const Object(),
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
        const ComicMedia(
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
    final candidates = libraryKindModuleForKind(CatalogMediaKind.anime)
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

Iterable<String?> _comicPublisher(ComicMedia metadata) => [
      metadata.publisher,
    ];

ComicMedia? _comicMetadataReader(LibraryWorkspaceSource source) {
  final metadata = source.catalogTransport?.toTransportItem().kindMetadata;
  return metadata is ComicMedia ? metadata : null;
}

LibraryWorkspaceSource _shelfEntry(
  CatalogMediaKind kind,
  Object? metadata, {
  String? title,
}) {
  final transport = CatalogItemDto(
    identity: LibraryItemIdentity(id: 'item-1', mediaKind: kind),
    kindMetadata: metadata,
  ).asShelfCatalogItem;
  return LibraryWorkspaceSource(
    itemId: 'item-1',
    catalogSummary: title == null
        ? null
        : CatalogDisplaySummary.work(
            kind: kind,
            id: 'item-1',
            title: title,
          ),
    catalogSearchTokens: [
      transport.title,
      ...?transport.searchAliases,
    ],
    catalogTransport: transport,
  );
}
