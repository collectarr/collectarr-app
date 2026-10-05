import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_export_preview_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';

final Map<CatalogMediaKind, LibraryExportPreviewContributor>
    collectionExportPreviewContributorsByKind = {
  CatalogMediaKind.comic: const ComicExportPreviewContributor(),
};
