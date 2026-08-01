import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceDto extends WorkspaceDtoAdapter {
  MangaWorkspaceDto({
    required this.common,
    required this.personal,
    required this.manga,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final BookCatalogItem manga;
}
