import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class MangaWorkspaceCatalogData implements LibraryWorkspaceCatalogData {
  MangaWorkspaceCatalogData({
    required this.ref,
    required this.metadata,
  });

  factory MangaWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    return MangaWorkspaceCatalogData(
      ref: item.catalogRef,
      metadata: rawMetadata is MangaMetadata
          ? rawMetadata
          : MangaMetadata.fromJson(item.payload),
    );
  }

  @override
  final CatalogEntityRef ref;
  final MangaMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;
  @override
  String get title => metadata.title;
  @override
  String? get synopsis => null;
  @override
  DateTime? get releaseDate =>
      metadata.localizedReleaseDate ?? metadata.originalPublicationDate;
  @override
  String? get coverImageUrl => metadata.coverImageUrl;
  @override
  String? get thumbnailImageUrl => metadata.thumbnailImageUrl;
}
