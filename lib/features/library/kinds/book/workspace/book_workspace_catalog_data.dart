import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class BookWorkspaceCatalogData
    implements
        LibraryWorkspaceCatalogData,
        LibraryWorkspaceCatalogSynopsisData {
  BookWorkspaceCatalogData({
    required this.ref,
    required this.catalogTitle,
    required this.book,
    required this.metadata,
    this.catalogReleaseDate,
    this.catalogCoverImageUrl,
  });

  factory BookWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    return BookWorkspaceCatalogData(
      ref: item.catalogRef,
      catalogTitle: item.title,
      book: BookCatalogMapper.mapMetadataItemToBook(item),
      catalogReleaseDate: item.releaseDate,
      catalogCoverImageUrl: item.displayCoverUrl,
      metadata: rawMetadata is BookCatalogMetadata
          ? rawMetadata
          : rawMetadata == null
              ? null
              : BookCatalogMetadata.fromJson(item.toSyncPayload()),
    );
  }

  @override
  final CatalogEntityRef ref;
  final String catalogTitle;
  final BookCatalogItem book;
  final BookCatalogMetadata? metadata;
  final DateTime? catalogReleaseDate;
  final String? catalogCoverImageUrl;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;
  @override
  String get title => catalogTitle;
  @override
  String? get synopsis => metadata?.synopsis ?? book.synopsis;
  @override
  DateTime? get releaseDate => catalogReleaseDate;
  @override
  String? get coverImageUrl => catalogCoverImageUrl;
  @override
  String? get thumbnailImageUrl => book.thumbnailImageUrl;
}
