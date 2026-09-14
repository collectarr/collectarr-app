import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_mapper.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';

final class MusicWorkspaceCatalogData implements LibraryWorkspaceCatalogData {
  MusicWorkspaceCatalogData({
    required this.ref,
    required this.music,
    required this.release,
    required CatalogItemDto transport,
  }) : _transport = transport;

  factory MusicWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    final music = rawMetadata is MusicReleaseGroup
        ? rawMetadata
        : MusicCatalogMapper.mapMetadataItemToMusic(item);
    final release = rawMetadata is MusicRelease
        ? rawMetadata
        : music.primaryRelease ??
            MusicRelease.fromJson({
              ...item.payload,
              'id': '${music.id.value}:release',
              'release_group_id': music.id.value,
              'kind': 'music',
              'title': music.title,
              if (music.originalReleaseDate != null)
                'release_date': music.originalReleaseDate!.toIso8601String(),
              if (music.coverImageUrl != null)
                'cover_image_url': music.coverImageUrl,
            });
    return MusicWorkspaceCatalogData(
      ref: item.catalogRef,
      music: music,
      release: release,
      transport: item,
    );
  }

  @override
  final CatalogEntityRef ref;
  final MusicReleaseGroup music;
  final MusicRelease release;
  final CatalogItemDto _transport;

  MusicRelease releaseFor({String? releaseId, CatalogEditionDto? edition}) {
    return MusicWorkspaceMapper.fromCatalogItem(
      _transport,
      releaseId: releaseId,
      edition: edition,
    );
  }

  MusicRelease releaseForSummary(LibraryWorkspaceReleaseSummary summary) {
    return releaseFor(
      releaseId: summary.id,
      edition: CatalogEditionDto(
        id: summary.id,
        title: summary.title,
        physicalFormatLabel: summary.formatLabel,
        variants: [
          for (final variant in summary.variants)
            CatalogVariantDto(
              id: variant.id,
              name: variant.name,
              sku: variant.sku,
              coverImageUrl: variant.coverImageUrl,
              thumbnailImageUrl: variant.thumbnailImageUrl,
              physicalFormatLabel: variant.formatLabel,
              isPrimary: variant.isPrimary,
            ),
        ],
        releaseDate: summary.releaseDate,
      ),
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
  String? get thumbnailImageUrl => release.coverImageUrl ?? music.coverImageUrl;
}
