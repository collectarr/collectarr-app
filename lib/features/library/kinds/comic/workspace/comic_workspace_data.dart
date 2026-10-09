import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class ComicWorkspaceData implements LibraryWorkspaceKindData {
  ComicWorkspaceData({
    required this.comic,
  });

  factory ComicWorkspaceData.fromTransport(CatalogItemDto item) {
    return ComicWorkspaceData(
      comic: ComicCatalogItem.fromJson(item.payload),
    );
  }

  final ComicCatalogItem comic;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;
  @override
  String get displayLabel => comic.title;
}
