import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BookWorkspaceDto extends WorkspaceDtoAdapter {
  BookWorkspaceDto({
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
  int? get pageCount => book.publishing.pageCount;
  String? get imprint => book.publishing.imprint;
  String? get author => book.work.creators.firstOrNull?.name;
  String? get isbn => book.releases.firstOrNull?.isbn;
}
