import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class TvWorkspaceCatalogData
    implements
        LibraryWorkspaceCatalogData,
        LibraryWorkspaceCatalogSynopsisData {
  TvWorkspaceCatalogData({
    required this.ref,
    required this.metadata,
  });

  factory TvWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final metadataPayload = item.kindData;
    final metadata = TvMetadata.fromJson(metadataPayload);
    return TvWorkspaceCatalogData(
      ref: item.catalogRef,
      metadata: metadata,
    );
  }

  @override
  final CatalogEntityRef ref;
  final TvMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;
  @override
  String get title => metadata.title;
  @override
  String? get synopsis => metadata.synopsis;
  @override
  DateTime? get releaseDate => metadata.releaseDate ?? metadata.firstAirDate;
  @override
  String? get coverImageUrl => metadata.coverImageUrl;
  @override
  String? get thumbnailImageUrl => metadata.thumbnailImageUrl ?? coverImageUrl;
}
