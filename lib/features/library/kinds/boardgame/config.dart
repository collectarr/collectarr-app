import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const boardGamesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.boardgame,
  title: 'Board Games',
  icon: Icons.casino_outlined,
  accent: Color(0xFFE0A52B),
  preferencePrefix: 'boardgames',
);

final boardgameTransferableFields = <TransferableField>[
  TransferableField(
    key: 'isSleeved',
    label: 'Sleeved',
    icon: Icons.shield_outlined,
    type: TransferableFieldType.boolean,
    read: (item) => (item.boardgameDetails?.isSleeved == true) ? 'true' : null,
    write: (item, value) {
      final b = item.boardgameDetails ?? const BoardgameOwnedDetails();
      return item.copyWith(details: b.copyWith(isSleeved: value == 'true'));
    },
  ),
  TransferableField(
    key: 'hasCustomInsert',
    label: 'Custom insert',
    icon: Icons.grid_view_outlined,
    type: TransferableFieldType.boolean,
    read: (item) =>
        (item.boardgameDetails?.hasCustomInsert == true) ? 'true' : null,
    write: (item, value) {
      final b = item.boardgameDetails ?? const BoardgameOwnedDetails();
      return item.copyWith(
          details: b.copyWith(hasCustomInsert: value == 'true'));
    },
  ),
];

final boardGamesLibraryConfig = LibraryTypeConfig(
  workspace: boardGamesWorkspaceConfig,
  singularLabel: 'Board Game',
  pluralLabel: 'Board Games',
  defaultMetadataProvider: 'bgg',
  metadataProviders: [
    bggMetadataProvider,
  ],
  trackingProfile: gameTrackingProfile,
  presentation: boardGamesLibraryMediaPresentation,
  capabilities: LibraryTypeCapabilities(
    canScanCover: true,
  ),
);
