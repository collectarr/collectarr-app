import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryTypedFacets Tests', () {
    test('LibraryFacetId equality and formatting', () {
      const facetId1 = LibraryFacetId<ComicKind, String>('publisher');
      const facetId2 = LibraryFacetId<ComicKind, String>('publisher');
      const facetId3 = LibraryFacetId<ComicKind, String>('series');
      const dynamicFacet = DynamicLibraryFacetId('publisher');

      expect(facetId1, equals(facetId2));
      expect(facetId1.hashCode, equals(facetId2.hashCode));
      expect(facetId1, isNot(equals(facetId3)));
      expect(facetId1.value, 'publisher');
      expect(facetId1.toString(), 'publisher');
      expect(dynamicFacet.value, 'publisher');
      expect(dynamicFacet.toString(), 'publisher');
    });

    test('LibraryFacetQuery uses typed facet identifier', () {
      const query = LibraryFacetQuery<String>(
        facetId: LibraryFacetId<ComicKind, String>('publisher'),
        searchQuery: 'Marvel',
        limit: 20,
      );

      expect(query.facetId.value, 'publisher');
      expect(query.searchQuery, 'Marvel');
      expect(query.limit, 20);
      expect(query.offset, 0);
    });

    test('LibraryFacetBucket stores typed value and count', () {
      const bucket = LibraryFacetBucket<String>(
        key: 'marvel',
        label: 'Marvel Comics',
        count: 42,
        value: 'Marvel Comics',
      );

      expect(bucket.key, 'marvel');
      expect(bucket.label, 'Marvel Comics');
      expect(bucket.count, 42);
      expect(bucket.value, 'Marvel Comics');
    });

    test('LibraryFacetDefinition extracts values from DTO', () {
      final facetDef =
          LibraryFacetDefinition<dynamic, ComicWorkspaceDto, String>(
        id: const LibraryTypedFacetId<dynamic, String>('publisher'),
        label: 'Publisher',
        extractValues: (dto) => dto.comic.publishing.publisher != null
            ? [dto.comic.publishing.publisher!]
            : const [],
      );

      final dtoWithPublisher = ComicWorkspaceDto(
        common: const WorkspaceCommonProjection(title: 'Spider-Man'),
        personal: PersonalCopyProjection(),
        comic: const ComicCatalogItem(
          id: '1',
          work: ComicWorkMetadata(title: 'Spider-Man'),
          publishing: ComicPublishingMetadata(publisher: 'Marvel Comics'),
          releases: [],
        ),
      );
      final dtoWithoutPublisher = ComicWorkspaceDto(
        common: const WorkspaceCommonProjection(title: 'Indie Comic'),
        personal: PersonalCopyProjection(),
        comic: const ComicCatalogItem(
          id: '2',
          work: ComicWorkMetadata(title: 'Indie Comic'),
          publishing: ComicPublishingMetadata(),
          releases: [],
        ),
      );

      expect(
          facetDef.extractValues(dtoWithPublisher), equals(['Marvel Comics']));
      expect(facetDef.extractValues(dtoWithoutPublisher), isEmpty);
    });
  });
}
