import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

/// Maps the flat Core TV Catalog Item response into TV-owned contained data.
final class TvCoreMapper {
  const TvCoreMapper._();

  static TvSeries fromCatalogItemJson(Map<String, dynamic> json) {
    final item = CatalogItemDto.fromJson(json);
    if (item.mediaKind != CatalogMediaKind.tv) {
      throw StateError('TV Core mapping received ${item.kind} data');
    }
    return TvSeries.fromJson(catalogTransportPayloadFor(item));
  }
}
