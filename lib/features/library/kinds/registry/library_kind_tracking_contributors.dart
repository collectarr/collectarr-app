import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_workspace_registry.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';

MediaTrackingProfile libraryTrackingProfileForKind(CatalogMediaKind kind) =>
    collectarrKindTrackingProfiles[kind]!;
