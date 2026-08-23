import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/game/game_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/game/inspector_panel.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_fields.dart';

import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';

final gameKindModule = LibraryKindSpec<GameWorkspaceDto, GameOwnedDetails>(
  type: gamesLibraryConfig,
  mediaAdapter: gamesMediaAdapter,
  projector: const GameWorkspaceProjector(),
  ownedDetailsCodec: const GameOwnedDetailsCodec(),
  fields: gameLibraryKindSchema.toRegistry(),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.game,
    singularLabel: 'Game',
    pluralLabel: 'Games',
    title: 'Games',
    icon: Icons.sports_esports,
    accent: Color(0xFFF64458),
    preferencePrefix: 'games',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'igdb',
    providers: [igdbMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.flat,
    supportsSeriesSubgroups: true,
    supportsMediaReleaseSplit: true,
    collectionExportTitleLabel: 'Title',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    sectionsBuilder: buildGameInspectorSections,
    showsDefaultPersonalSection: false,
  ),
  transfer: const LibraryTransferCapability(),
  add: const StandardLibraryAddCapability<GameAddDraft>(
    kind: CatalogMediaKind.game,
    initialDraftBuilder: GameAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    gamesLibraryConfig,
    createDraft: createGameEditDraft,
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(),
  providerMapper: const GameLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildGameCardPresentation,
);
