import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class MangaWorkspaceData implements LibraryWorkspaceKindData {
  MangaWorkspaceData({
    required this.metadata,
  });

  factory MangaWorkspaceData.fromTransport(CatalogItemDto item) {
    return MangaWorkspaceData(
      metadata: MangaMetadata.fromJson(item.payload),
    );
  }

  final MangaMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;
  @override
  String get displayLabel => metadata.title;
}
