import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_kind_transport_codec_defaults.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/data.dart';

final class BoardGameCatalogTransportCodec
    with CatalogKindTransportCodecDefaults<BoardGameMetadata> {
  const BoardGameCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  BoardGameMetadata decode(CatalogItemDto item) =>
      BoardGameMetadata.fromJson(item.kindData);

  @override
  BoardGameMetadata decodeKindData(Map<String, dynamic> kindData) =>
      BoardGameMetadata.fromJson(kindData);

  @override
  CatalogItemDto encode(String id, BoardGameMetadata item) =>
      CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        kindData: item.toJson(),
      );

  @override
  CatalogDisplaySummary summarize(
    String catalogItemId,
    BoardGameMetadata item,
  ) =>
      CatalogDisplaySummary.forCatalogItem(
        kind: kind,
        id: catalogItemId,
        primaryLabel: item.title,
        imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
      );

  @override
  BoardGameWorkspaceData workspaceData(CatalogItemDto item) =>
      BoardGameWorkspaceData(metadata: decode(item));

  @override
  BoardGameWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      BoardGameWorkspaceData(metadata: BoardGameMetadata.fromJson(kindData));
}
