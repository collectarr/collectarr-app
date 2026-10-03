import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class BoardGameWorkspaceCatalogData
    implements
        LibraryWorkspaceCatalogData,
        LibraryWorkspaceCatalogSynopsisData {
  BoardGameWorkspaceCatalogData({
    required this.ref,
    required this.metadata,
  });

  factory BoardGameWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    return BoardGameWorkspaceCatalogData(
      ref: item.catalogRef,
      metadata: BoardGameMetadata.fromJson(item.kindData),
    );
  }

  @override
  final CatalogEntityRef ref;
  final BoardGameMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;
  @override
  String get title => metadata.title;
  @override
  String? get synopsis => metadata.synopsis;
  @override
  DateTime? get releaseDate =>
      metadata.releaseDate?.asDateTime ??
      metadata.releaseDateParts?.asDateTime ??
      (metadata.yearPublished == null
          ? null
          : DateTime(metadata.yearPublished!));
  @override
  String? get coverImageUrl => metadata.coverImageUrl;
  @override
  String? get thumbnailImageUrl =>
      metadata.thumbnailImageUrl ?? metadata.coverImageUrl;
}
