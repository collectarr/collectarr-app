import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/book/data/remote/book_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_hierarchy_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps Book editions and variants without TV Season semantics', () {
    final dto = BookWorkDto.fromJson({
      'id': 'book-1',
      'kind': 'book',
      'title': 'Dune',
      'editions': [
        {
          'id': 'edition-1',
          'work_id': 'book-1',
          'display_title': 'Hardcover',
          'format': 'hardcover',
          'page_count': 412,
          'publication_date': '2024-05-01T00:00:00Z',
          'variants': [
            {
              'id': 'variant-1',
              'name': 'First cover',
              'physical_format_label': 'Illustrated hardcover',
              'is_primary': true,
            },
          ],
        },
        {
          'id': 'edition-2',
          'work_id': 'book-1',
          'title': 'Paperback',
          'format': 'paperback',
        },
      ],
    });

    final nodes = BookHierarchyMapper.toLibraryNodes(
      BookCoreMapper.fromWorkDto(dto).editions,
    );

    expect(nodes, hasLength(2));
    expect(nodes[0].id, 'edition-1');
    expect(nodes[0].level, LibraryHierarchyLevel.container);
    expect(nodes[0].secondaryLabel, 'hardcover · 2024 · 412 pages');
    expect(nodes[0].metadata['kind'], 'book_release');
    expect(nodes[0].metadata['releaseStatus'], isNull);
    expect(nodes[0].children, hasLength(1));
    expect(nodes[0].children.single.id, 'edition-1::variant-1');
    expect(nodes[0].children.single.label, 'First cover');
    expect(
      nodes[0].children.single.secondaryLabel,
      'Illustrated hardcover',
    );
    expect(nodes[0].children.single.metadata['kind'], 'book_variant');
    expect(nodes[1].level, LibraryHierarchyLevel.leaf);
  });

  test('uses a stable fallback identity for an incomplete release', () {
    final nodes = BookHierarchyMapper.toLibraryNodes([
      const BookRelease(id: '', title: 'Untitled edition'),
    ]);

    expect(nodes.single.id, 'release-1');
    expect(nodes.single.metadata['releaseId'], isEmpty);
  });
}
