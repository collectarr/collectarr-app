export 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_release.dart';

// Transitional typedefs to avoid parallel domain models while existing components migrate.
typedef BoardGameWork = BoardGameCatalogItem;
typedef BoardGameEdition = BoardGameRelease;
typedef BoardGamePlayStats = BoardGameStatsMetadata;
