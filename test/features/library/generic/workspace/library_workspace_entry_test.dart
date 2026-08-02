import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book media falls back to primary release cover and reference ids', () {
    final item = BookCatalogItem(
      id: 'book-1',
      work: const BookWorkMetadata(title: 'Example Book'),
      publishing: const BookPublishingMetadata(),
      releases: [
        BookRelease(
          id: 'edition-1',
          title: 'Hardcover',
          variants: [
            BookVariantRef(
              id: 'variant-1',
              name: 'Hardcover',
              coverImageUrl: 'https://example.test/release-cover.jpg',
              isPrimary: true,
            ),
          ],
        ),
      ],
    );

    final dto = BookWorkspaceDto(
      common: WorkspaceCommonProjection(
        title: item.work.title,
        coverImageUrl:
            item.releases.firstOrNull?.variants.firstOrNull?.coverImageUrl,
      ),
      personal: PersonalCopyProjection(),
      book: item,
    );

    expect(dto.coverImageUrl, 'https://example.test/release-cover.jpg');
    expect(dto.book.releases, hasLength(1));
  });
}
