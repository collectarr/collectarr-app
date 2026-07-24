export 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_release.dart';

// Transitional typedefs to avoid parallel domain models while existing components migrate.
typedef MovieWork = VideoCatalogItem;
typedef MovieRelease = VideoRelease;
typedef MovieReleaseMedia = VideoMediaRef;
