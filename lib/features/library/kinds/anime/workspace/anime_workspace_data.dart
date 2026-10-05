import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class AnimeWorkspaceData implements LibraryWorkspaceKindData {
  AnimeWorkspaceData({
    required this.metadata,
  });

  factory AnimeWorkspaceData.fromTransport(CatalogItemDto item) {
    return AnimeWorkspaceData(
      metadata: AnimeMetadata.fromJson(item.kindData),
    );
  }

  final AnimeMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;
  @override
  String get displayLabel => metadata.title;
}
