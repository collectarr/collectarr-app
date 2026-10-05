import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/library_filters.dart';
import 'package:collectarr_app/features/library/config/presentation/library_filter_presentation.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  test('location filter matches exact location path', () {
    final source = LibraryWorkspaceSource(
      itemId: 'comic-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Batman',
      ).asShelfCatalogItem),
      locationPath: 'Office > Shelf 2 > Short Box 1',
    );
    const node = LibraryCatalogItemNodeRef(catalogItemId: 'comic-1');
    final dto = const ComicWorkspaceProjector().project(
      source: source,
      entity: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    expect(
      libraryFilterMatches(
        item,
        const LibraryFilterSelection(
          fieldValues: {
            'location': 'Office > Shelf 2 > Short Box 1',
          },
        ),
      ),
      isTrue,
    );
    expect(
      libraryFilterMatches(
        item,
        const LibraryFilterSelection(
          fieldValues: {'location': 'Office > Shelf 2'},
        ),
      ),
      isFalse,
    );
  });

  test('tag filter matches exact tag case-insensitively', () {
    final source = testLibraryWorkspaceSource(
      itemId: 'comic-1',
      kind: 'comic',
      title: 'Batman',
      libraryEntry: testLibraryEntry(
        id: 'entry-1',
        itemId: 'comic-1',
        tags: 'Signed, Slabbed, Variant',
      ),
    );
    const node = LibraryCatalogItemNodeRef(catalogItemId: 'comic-1');
    final dto = const ComicWorkspaceProjector().project(
      source: source,
      entity: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    expect(
      libraryFilterMatches(
        item,
        const LibraryFilterSelection(fieldValues: {'tag': 'signed'}),
        filterDefinitions: comicKindPresentation.filterDefinitions,
      ),
      isTrue,
    );
    expect(
      libraryFilterMatches(
        item,
        const LibraryFilterSelection(fieldValues: {'tag': 'Exclusive'}),
        filterDefinitions: comicKindPresentation.filterDefinitions,
      ),
      isFalse,
    );
  });

  test('filter selection sanitization drops unsupported grade filters', () {
    const selection = LibraryFilterSelection(
      fieldValues: {
        'grade': LibraryFilterDefinition.missingValue,
        'condition': 'Mint',
        'publisher': 'DC',
        'country': 'US',
      },
    );

    final sanitizedMusic = sanitizeLibraryFilterSelectionForType(
      selection,
      const MusicRegistration(),
    );
    expect(sanitizedMusic.entriesFilter, LibraryEntryPolicyFilter.all);
    expect(sanitizedMusic.fieldValue('grade'), isNull);
    expect(sanitizedMusic.fieldValue('condition'), 'Mint');
    expect(sanitizedMusic.fieldValue('publisher'), 'DC');
    expect(sanitizedMusic.fieldValue('country'), 'US');

    final sanitizedComics = sanitizeLibraryFilterSelectionForType(
      selection,
      const ComicRegistration(),
    );
    expect(sanitizedComics.entriesFilter, LibraryEntryPolicyFilter.all);
    expect(
      sanitizedComics.fieldValue('grade'),
      LibraryFilterDefinition.missingValue,
    );
  });

}
