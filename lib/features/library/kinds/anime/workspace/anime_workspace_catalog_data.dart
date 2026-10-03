import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class AnimeWorkspaceCatalogData
    implements
        LibraryWorkspaceCatalogData,
        LibraryWorkspaceCatalogSynopsisData {
  AnimeWorkspaceCatalogData({
    required this.ref,
    required this.metadata,
  });

  factory AnimeWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    return AnimeWorkspaceCatalogData(
      ref: item.catalogRef,
      metadata: AnimeMetadata.fromJson(item.kindData),
    );
  }

  @override
  final CatalogEntityRef ref;
  final AnimeMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;
  @override
  String get title => metadata.title;
  @override
  String? get synopsis => metadata.synopsis;
  @override
  DateTime? get releaseDate => metadata.startDate ?? metadata.releaseDate;
  @override
  String? get coverImageUrl => metadata.coverImageUrl;
  @override
  String? get thumbnailImageUrl => metadata.thumbnailImageUrl ?? coverImageUrl;
}
