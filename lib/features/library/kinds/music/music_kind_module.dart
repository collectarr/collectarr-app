import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';

import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';

final musicKindModule = LibraryKindSpec<MusicWorkspaceDto, MusicOwnedDetails>(
  type: musicLibraryConfig,
  projector: const MusicWorkspaceProjector(),
  ownedDetailsCodec: const MusicOwnedDetailsCodec(),
  fields: musicLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<MusicCatalogMetadata>(
    MusicCatalogMetadata.fromJson,
    _encodeMusicMetadata,
  ),
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
    childrenTitleBuilder: _musicChildrenTitle,
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
    manualDraftBuilder: MusicAddManualDraft.new,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildMusicLibraryEditDialog,
    presentation: musicLibraryEditPresentation,
    mediaFields: const MediaEditFields(
      numberLabel: 'Disc / Volume',
      publisherLabel: 'Label',
      releaseDateLabel: 'Original release date',
    ),
    releaseFields: const ReleaseEditFields(
      variantLabel: 'Format / Edition',
      barcodeLabel: 'Barcode / Catalog no.',
    ),
    createDraft: createMusicEditDraft,
  ),
  providerMapper: const MusicLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildMusicCardPresentation,
);

String _musicChildrenTitle(int count) => 'Discs ($count)';

Map<String, dynamic> _encodeMusicMetadata(MusicCatalogMetadata m) => m.toJson();

