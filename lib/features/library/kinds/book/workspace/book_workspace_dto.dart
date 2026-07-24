import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class BookWorkspaceDto extends WorkspaceDtoAdapter {
  const BookWorkspaceDto({
    required this.common,
    required this.personal,
    required this.book,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final BookCatalogItem book;

  // Domain convenience getters delegating to BookCatalogItem:
  int get pageCount => book.publishing.pageCount ?? 0;
  String? get imprint => book.publishing.imprint;
  String? get author => book.work.creators.firstOrNull?.name;
  String? get isbn => book.releases.firstOrNull?.isbn;

  factory BookWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    final bookCatalogItem = BookCatalogMapper.mapWorkspaceEntryToBook(entry);

    return BookWorkspaceDto(
      common: WorkspaceCommonProjection(
        title: entry.resolvedTitle,
        seriesTitle: entry.series?.seriesTitle,
        itemNumber: entry.itemNumber,
        publisher: entry.publisher,
        releaseDate: entry.releaseDate,
        variant: entry.variant,
        barcode: entry.barcode,
        grade: entry.grade,
        country: entry.country,
        language: entry.language,
        currency: entry.currency,
        referenceFormatLabel: entry.referenceFormatLabel,
        coverImageUrl: entry.coverImageUrl,
      ),
      personal: PersonalCopyProjection(
        isOwned: entry.isOwned,
        isWishlisted: entry.isWishlisted,
        condition: entry.condition,
        locationPath: entry.locationPath,
        rating: entry.rating,
        pricePaidCents: entry.pricePaidCents,
        addedAt: entry.addedAt,
        updatedAt: entry.updatedAt,
        tags: entry.tags,
        collectionStatus: entry.collectionStatus,
      ),
      book: bookCatalogItem,
    );
  }
}
