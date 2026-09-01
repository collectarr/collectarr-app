import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const gamesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.game,
  title: 'Games',
  icon: Icons.sports_esports,
  accent: Color(0xFFF64458),
  preferencePrefix: 'games',
);

final gamesLibraryConfig = LibraryTypeConfig(
  workspace: gamesWorkspaceConfig,
  singularLabel: 'Game',
  pluralLabel: 'Games',
  defaultMetadataProvider: 'igdb',
  metadataProviders: [
    igdbMetadataProvider,
  ],
  trackingProfile: gameTrackingProfile,
  presentation: gamesLibraryMediaPresentation,
  capabilities: LibraryTypeCapabilities(
    canScanCover: true,
    supportsMediaReleaseSplit: true,
  ),
);
