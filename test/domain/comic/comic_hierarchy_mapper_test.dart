import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Comic hierarchy maps typed releases and variants directly', () {
    final media = ComicMedia(
      id: const ComicMediaId('series-1'),
      title: 'Saga',
      releases: [
        ComicRelease(
          id: 'issue-1',
          title: 'Saga #1',
          publisher: 'Image',
          variants: const [
            CatalogVariantDto(
              id: 'variant-1',
              name: 'Newsstand',
              physicalFormatLabel: 'Single issue',
            ),
          ],
        ),
      ],
    );

    final nodes = ComicHierarchyMapper.toLibraryNodes(media);
    expect(nodes, hasLength(1));
    expect(nodes.single.level, LibraryHierarchyLevel.container);
    expect(nodes.single.label, 'Saga #1');
    expect(nodes.single.children.single.level, LibraryHierarchyLevel.leaf);
    expect(nodes.single.children.single.secondaryLabel, 'Single issue');
    expect(nodes.single.metadata['kind'], 'comic_release');
  });

  test('Comic hierarchy returns an empty list when Core has no releases', () {
    expect(
      ComicHierarchyMapper.toLibraryNodes(
        const ComicMedia(title: 'Empty series'),
      ),
      isEmpty,
    );
  });
}
