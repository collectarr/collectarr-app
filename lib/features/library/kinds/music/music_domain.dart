import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';

export 'package:collectarr_app/features/library/kinds/music/contracts/music_contracts.dart';
export 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
export 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
export 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
export 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
export 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
export 'package:collectarr_app/features/library/kinds/music/domain/music_hierarchy_mapper.dart';
export 'package:collectarr_app/features/library/kinds/music/domain/music_tracking.dart';
export 'package:collectarr_app/features/library/kinds/music/data/remote/music_core_mapper.dart';
export 'package:collectarr_app/features/library/kinds/music/data/remote/music_remote_source.dart';
export 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_mapper.dart';
export 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_integration.dart';
export 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
export 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
export 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
export 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
export 'package:collectarr_app/features/library/kinds/music/add/music_release_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';
export 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
export 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
export 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_mapper.dart';
export 'package:collectarr_app/features/library/kinds/music/edit/music_media_edit_draft.dart';
export 'package:collectarr_app/features/library/kinds/music/edit/music_media_edit_schema.dart';
export 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_draft.dart';
export 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_schema.dart';
export 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
export 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_schema.dart';
export 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
export 'package:collectarr_app/features/library/kinds/music/stats/music_stats_capability.dart';

// Transitional typedefs to avoid parallel domain models while existing components migrate.
typedef MusicWork = MusicCatalogItem;
