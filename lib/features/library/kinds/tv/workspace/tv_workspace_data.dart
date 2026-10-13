import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class TvWorkspaceData implements LibraryWorkspaceKindData {
  TvWorkspaceData({
    required this.metadata,
  });

  factory TvWorkspaceData.fromTransport(CatalogItemDto item) {
    final metadataPayload = item.kindData;
    final metadata = TvMetadata.fromJson(metadataPayload);
    return TvWorkspaceData(
      metadata: metadata,
    );
  }

  final TvMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;
  @override
  String get displayLabel => metadata.title;
}
