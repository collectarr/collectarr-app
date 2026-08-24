import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';

export 'package:collectarr_app/features/library/kinds/music/contracts/music_contracts.dart';
export 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
export 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
export 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';
export 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
export 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';

// Transitional typedefs to avoid parallel domain models while existing components migrate.
typedef MusicWork = MusicCatalogItem;
typedef MusicMedia = MusicDiscRef;
typedef MusicTrack = MusicTrackRef;
