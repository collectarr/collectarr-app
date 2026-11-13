import 'package:collectarr_app/features/library/kinds/comic/domain/comic_issue_label.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_kind_transport_codec_defaults.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';

final class ComicCatalogTransportCodec
    with CatalogKindTransportCodecDefaults<ComicCatalogItem> {
  const ComicCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  ComicCatalogItem decode(CatalogItemDto item) =>
      ComicCatalogItem.fromJson(catalogTransportPayloadFor(item));

  @override
  ComicCatalogItem decodeKindData(Map<String, dynamic> kindData) =>
      ComicCatalogItem.fromJson(kindData);

  @override
  CatalogItemDto encode(String id, ComicCatalogItem item) => CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        kindData: item.toJson(),
      );

  @override
  CatalogDisplaySummary summarize(
          String catalogItemId, ComicCatalogItem item) =>
      _comicSummary(catalogItemId, item);

  @override
  ComicWorkspaceData workspaceData(CatalogItemDto item) =>
      ComicWorkspaceData(comic: decode(item));

  @override
  ComicWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      ComicWorkspaceData(comic: ComicCatalogItem.fromJson(kindData));
}

CatalogDisplaySummary _comicSummary(
    String catalogItemId, ComicCatalogItem item) {
  return CatalogDisplaySummary.forCatalogItem(
    kind: CatalogMediaKind.comic,
    id: catalogItemId,
    primaryLabel: comicHeadline(
          series: item.seriesTitle,
          issueNumber: item.issueNumber,
          variant: item.variant,
          title: item.title,
        ) ??
        item.title,
    imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
  );
}
