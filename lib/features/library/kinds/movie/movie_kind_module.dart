import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_media_adapter.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/detail/video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/movie/inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_fields.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:collectarr_app/features/library/kinds/movie/stats/movie_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';

final movieKindModule = LibraryKindSpec<MovieWorkspaceDto, MovieOwnedDetails>(
  type: moviesLibraryConfig,
  mediaAdapter: moviesMediaAdapter,
  projector: const MovieWorkspaceProjector(),
  ownedDetailsCodec: const MovieOwnedDetailsCodec(),
  fields: movieLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<MovieCatalogMetadata>(
    MovieCatalogMetadata.fromJson,
    _encodeMovieMetadata,
  ),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.movie,
    singularLabel: 'Movie',
    pluralLabel: 'Movies',
    title: 'Movies',
    icon: Icons.movie_outlined,
    accent: Color(0xFF42AA55),
    preferencePrefix: 'movies',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'tmdb',
    providers: [tmdbMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.flat,
    supportsMediaReleaseSplit: true,
    collectionExportTitleLabel: 'Title',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    sectionsBuilder: buildMovieInspectorSections,
    detailPageBuilder: buildVideoLibraryDetailPage,
  ),
  transfer: LibraryTransferCapability(
    kindFields: movieTransferableFields,
  ),
  stats: const MovieStatsCapability(),
  add: const StandardLibraryAddCapability<MovieAddDraft>(
    kind: CatalogMediaKind.movie,
    initialDraftBuilder: MovieAddDraft.new,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildMovieLibraryEditDialog,
    presentation: movieLibraryEditPresentation,
    mediaFields: const MediaEditFields(
      numberLabel: 'Edition no.',
      publisherLabel: 'Studio',
      releaseDateLabel: 'Release Date',
    ),
    releaseFields: const ReleaseEditFields(
      variantLabel: 'Format / Edition',
      barcodeLabel: 'UPC / Barcode',
    ),
    createDraft: createMovieEditDraft,
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(
    defaultVideoDisplayLevel: VideoDisplayLevel.titleWork,
    defaultVideoGrouping: VideoGroupingDefault.none,
    videoSeriesEntryTypes: {'tv'},
    videoShelfDrilldownEntryTypes: {'movie', 'tv', 'anime'},
  ),
  providerMapper: const MovieLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildMovieCardPresentation,
);

Map<String, dynamic> _encodeMovieMetadata(MovieCatalogMetadata m) => m.toJson();

