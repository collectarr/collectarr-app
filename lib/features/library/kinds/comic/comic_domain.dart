export 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';

// Transitional typedefs to avoid parallel domain models while existing components migrate.
typedef ComicWork = ComicCatalogItem;
typedef ComicIssue = ComicCatalogItem;
typedef ComicRelease = ComicRelease;
