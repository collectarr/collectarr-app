import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryTypedFacets Tests', () {
    test('LibraryTypedFacetId equality and formatting', () {
      const facetId1 = LibraryTypedFacetId<dynamic, String>('publisher');
      const facetId2 = LibraryTypedFacetId<dynamic, String>('publisher');
      const facetId3 = LibraryTypedFacetId<dynamic, String>('series');

      expect(facetId1, equals(facetId2));
      expect(facetId1.hashCode, equals(facetId2.hashCode));
      expect(facetId1, isNot(equals(facetId3)));
      expect(facetId1.toString(), 'LibraryTypedFacetId(publisher)');
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
