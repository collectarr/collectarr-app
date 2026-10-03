import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class BookWorkspaceCatalogData
    implements
        LibraryWorkspaceCatalogData,
        LibraryWorkspaceCatalogSynopsisData {
  BookWorkspaceCatalogData({
    required this.ref,
    required this.metadata,
  });

  factory BookWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    return BookWorkspaceCatalogData(
      ref: item.catalogRef,
      metadata: BookCatalogMetadata.fromJson(item.kindData),
    );
  }

  @override
  final CatalogEntityRef ref;
  final BookCatalogMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;
  @override
  String get title => metadata.title;
  @override
  String? get synopsis => metadata.synopsis;
  @override
  DateTime? get releaseDate =>
      metadata.releaseDate ?? metadata.releaseDateParts?.asDateTime;
  @override
  String? get coverImageUrl => metadata.coverImageUrl;
  @override
  String? get thumbnailImageUrl => metadata.thumbnailImageUrl ?? coverImageUrl;
}
