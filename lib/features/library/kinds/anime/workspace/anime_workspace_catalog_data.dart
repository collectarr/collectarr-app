import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/anime/catalog/anime_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_mapper.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class AnimeWorkspaceCatalogData implements LibraryWorkspaceCatalogData {
  AnimeWorkspaceCatalogData({
    required this.ref,
    required this.video,
    required this.media,
    required this.metadata,
    required CatalogItemDto transport,
  }) : _transport = transport;

  factory AnimeWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    return AnimeWorkspaceCatalogData(
      ref: item.catalogRef,
      video: AnimeCatalogMapper.mapMetadataItemToAnime(item),
      media: rawMetadata is AnimeMedia
          ? rawMetadata
          : AnimeWorkspaceMapper.fromCatalogItem(item),
      metadata: rawMetadata is AnimeMetadata
          ? rawMetadata
          : AnimeMetadata.fromJson(item.payload),
      transport: item,
    );
  }

  @override
  final CatalogEntityRef ref;
  final AnimeCatalogItem video;
  final AnimeMedia media;
  final AnimeMetadata? metadata;
  final CatalogItemDto _transport;

  CatalogItemDto get releaseTransport => _transport;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;
  @override
  String get title => video.work.title;
  @override
  String? get synopsis => video.work.synopsis;
  @override
  DateTime? get releaseDate => video.work.releaseDate;
  @override
  String? get coverImageUrl => media.coverImageUrl;
  @override
  String? get thumbnailImageUrl => media.thumbnailImageUrl ?? coverImageUrl;
}
