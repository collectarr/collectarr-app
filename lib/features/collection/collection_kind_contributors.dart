import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_export_preview_contributor.dart';
import 'package:collectarr_app/features/library/config/library_shelf_extension_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/comic_info/comic_info_export.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_shelf/manga_shelf_extension_contributor.dart';

final Map<CatalogMediaKind, LibraryShelfExtensionContributor>
    collectionShelfExtensionsByKind = {
  CatalogMediaKind.manga: const MangaShelfExtensionContributor(),
};

final Map<CatalogMediaKind, LibraryExportPreviewContributor>
    collectionExportPreviewContributorsByKind = {
  CatalogMediaKind.comic: const ComicExportPreviewContributor(),
};
