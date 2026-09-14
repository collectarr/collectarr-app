import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class BookWorkspaceCatalogData implements LibraryWorkspaceCatalogData {
  BookWorkspaceCatalogData({
    required this.ref,
    required this.book,
    required this.metadata,
  });

  factory BookWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    return BookWorkspaceCatalogData(
      ref: item.catalogRef,
      book: BookCatalogMapper.mapMetadataItemToBook(item),
      metadata: rawMetadata is BookCatalogMetadata
          ? rawMetadata
          : rawMetadata == null
              ? null
              : BookCatalogMetadata.fromJson(item.payload),
    );
  }

  @override
  final CatalogEntityRef ref;
  final BookCatalogItem book;
  final BookCatalogMetadata? metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;
  @override
  String get title => book.title;
  @override
  String? get synopsis => book.synopsis;
  @override
  DateTime? get releaseDate => book.releaseDate;
  @override
  String? get coverImageUrl => book.coverImageUrl;
  @override
  String? get thumbnailImageUrl => book.thumbnailImageUrl;
}
