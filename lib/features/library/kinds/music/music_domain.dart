export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';

// Transitional typedefs to avoid parallel domain models while existing components migrate.
typedef MusicWork = MusicCatalogItem;
typedef MusicRelease = MusicRelease;
typedef MusicMedia = MusicDiscRef;
typedef MusicTrack = MusicTrackRef;
