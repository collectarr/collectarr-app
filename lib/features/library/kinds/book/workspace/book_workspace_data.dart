import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class BookWorkspaceData implements LibraryWorkspaceKindData {
  BookWorkspaceData({
    required this.metadata,
  });

  factory BookWorkspaceData.fromTransport(CatalogItemDto item) {
    return BookWorkspaceData(
      metadata: BookCatalogMetadata.fromJson(item.kindData),
    );
  }

  final BookCatalogMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;
  @override
  String get displayLabel => metadata.title;
}
