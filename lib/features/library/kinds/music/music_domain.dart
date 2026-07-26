import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';

export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';

// Transitional typedefs to avoid parallel domain models while existing components migrate.
typedef MusicWork = MusicCatalogItem;
// MusicRelease is exported directly from music_catalog_release.dart (class MusicRelease)
typedef MusicMedia = MusicDiscRef;
typedef MusicTrack = MusicTrackRef;
