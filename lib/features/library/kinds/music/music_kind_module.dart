import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/music_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';

import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';

final musicKindModule = LibraryKindSpec<MusicWorkspaceDto, MusicOwnedDetails>(
  type: musicLibraryConfig,
  mediaAdapter: musicMediaAdapter,
  projector: const MusicWorkspaceProjector(),
  ownedDetailsCodec: const MusicOwnedDetailsCodec(),
  fields: musicLibraryKindSchema.toRegistry(),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.music,
    singularLabel: 'Music',
    pluralLabel: 'Music',
    title: 'Music',
    icon: Icons.music_note,
    accent: Color(0xFFFDAD49),
    preferencePrefix: 'music',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'musicbrainz',
    providers: [musicBrainzMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.flat,
    supportsSeriesSubgroups: true,
    supportsMediaReleaseSplit: true,
    collectionExportTitleLabel: 'Release',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
  ),
  transfer: const LibraryTransferCapability(),
  add: const StandardLibraryAddCapability<MusicAddDraft>(
    kind: CatalogMediaKind.music,
    initialDraftBuilder: MusicAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    musicLibraryConfig,
    createDraft: createMusicEditDraft,
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(
    supportsTrackSearch: true,
  ),
  providerMapper: const MusicLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildMusicCardPresentation,
);
