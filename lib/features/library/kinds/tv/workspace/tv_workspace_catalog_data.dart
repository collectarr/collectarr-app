import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_mapper.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class TvWorkspaceCatalogData implements LibraryWorkspaceCatalogData {
  TvWorkspaceCatalogData({
    required this.ref,
    required this.video,
    required this.series,
    required this.metadata,
  });

  factory TvWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    return TvWorkspaceCatalogData(
      ref: item.catalogRef,
      video: TvCatalogMapper.mapMetadataItemToTv(item),
      series: TvWorkspaceMapper.fromCatalogItem(item),
      metadata: rawMetadata is TvSeriesMetadata
          ? rawMetadata
          : rawMetadata == null
              ? null
              : TvSeriesMetadata.fromJson(item.payload),
    );
  }

  @override
  final CatalogEntityRef ref;
  final TvCatalogItem video;
  final TvSeries series;
  final TvSeriesMetadata? metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;
  @override
  String get title => video.work.title;
  @override
  String? get synopsis => video.work.synopsis;
  @override
  DateTime? get releaseDate => video.work.releaseDate;
  @override
  String? get coverImageUrl => video.primaryRelease?.frontCoverUrl;
  @override
  String? get thumbnailImageUrl => video.primaryRelease?.frontCoverUrl;
}
