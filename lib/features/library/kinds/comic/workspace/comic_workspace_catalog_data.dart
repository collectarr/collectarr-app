import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class ComicWorkspaceCatalogData implements LibraryWorkspaceCatalogData {
  ComicWorkspaceCatalogData({
    required this.ref,
    required this.comic,
  });

  factory ComicWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    return ComicWorkspaceCatalogData(
      ref: item.catalogRef,
      comic: rawMetadata is ComicMedia
          ? rawMetadata
          : ComicMedia.fromJson(item.payload),
    );
  }

  @override
  final CatalogEntityRef ref;
  final ComicMedia comic;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;
  @override
  String get title => comic.title;
  @override
  String? get synopsis => comic.synopsis;
  @override
  DateTime? get releaseDate => comic.releaseDate;
  @override
  String? get coverImageUrl => comic.coverImageUrl;
  @override
  String? get thumbnailImageUrl => comic.thumbnailImageUrl;
}
