import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_kind_transport_codec_defaults.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/data.dart';

final class BookCatalogTransportCodec
    with CatalogKindTransportCodecDefaults<BookCatalogMetadata> {
  const BookCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  BookCatalogMetadata decode(CatalogItemDto item) =>
      BookCatalogMetadata.fromJson(catalogTransportPayloadFor(item));

  @override
  BookCatalogMetadata decodeKindData(Map<String, dynamic> kindData) =>
      BookCatalogMetadata.fromJson(kindData);

  @override
  CatalogItemDto encode(String id, BookCatalogMetadata item) =>
      CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        kindData: item.toJson(),
      );

  @override
  CatalogDisplaySummary summarize(
    String catalogItemId,
    BookCatalogMetadata item,
  ) =>
      CatalogDisplaySummary.forCatalogItem(
        kind: kind,
        id: catalogItemId,
        primaryLabel: item.title,
        imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
      );

  @override
  BookWorkspaceData workspaceData(CatalogItemDto item) =>
      BookWorkspaceData(metadata: decode(item));

  @override
  BookWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      BookWorkspaceData(metadata: BookCatalogMetadata.fromJson(kindData));
}
