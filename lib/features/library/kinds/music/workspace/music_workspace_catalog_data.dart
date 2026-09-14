import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_mapper.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class MusicWorkspaceCatalogData implements LibraryWorkspaceCatalogData {
  MusicWorkspaceCatalogData({
    required this.ref,
    required this.music,
    required this.release,
    required this.metadata,
    required CatalogItemDto transport,
  }) : _transport = transport;

  factory MusicWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    return MusicWorkspaceCatalogData(
      ref: item.catalogRef,
      music: MusicCatalogMapper.mapMetadataItemToMusic(item),
      release: rawMetadata is MusicRelease
          ? rawMetadata
          : MusicRelease.fromJson(item.payload),
      metadata: rawMetadata is MusicCatalogMetadata
          ? rawMetadata
          : rawMetadata == null
              ? null
              : MusicCatalogMetadata.fromJson(item.payload),
      transport: item,
    );
  }

  @override
  final CatalogEntityRef ref;
  final MusicCatalogItem music;
  final MusicRelease release;
  final MusicCatalogMetadata? metadata;
  final CatalogItemDto _transport;

  MusicRelease releaseFor({String? releaseId, CatalogEditionDto? edition}) {
    return MusicWorkspaceMapper.fromCatalogItem(
      _transport,
      releaseId: releaseId,
      edition: edition,
    );
  }

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;
  @override
  String get title => music.title;
  @override
  String? get synopsis => music.synopsis;
  @override
  DateTime? get releaseDate => release.releaseDate ?? music.releaseDate;
  @override
  String? get coverImageUrl => release.coverImageUrl ?? music.coverImageUrl;
  @override
  String? get thumbnailImageUrl =>
      release.coverImageUrl ?? music.thumbnailImageUrl;
}
