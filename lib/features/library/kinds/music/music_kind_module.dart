import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/stats/music_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';

import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';

import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';

const _musicArtistFilterId = LibraryAddFilterId('music.artist');
const _musicLabelFilterId = LibraryAddFilterId('music.label');
const _musicYearFilterId = LibraryAddFilterId('music.year');

const _musicAddChrome = LibraryAddChromeConfig(
  mediaReferenceLabel: 'Album',
  trackScopeSummary:
      'Tracking stays album-level here. Edition and variant scope are only available for owned or wishlist entries.',
  mediaReferenceHelperLabel: 'Track or save the album itself.',
  editionReferenceHelperLabel:
      'Attach ownership to an album edition. Pick a variant only if you want one exact format or pressing.',
);

Iterable<String?> _musicLinkedMetadataValues(MusicCatalogMetadata metadata) => [
      metadata.artist,
      metadata.series?.seriesTitle,
      metadata.publisher,
      metadata.recordLabel,
      metadata.publishing?.originalPublisher,
      metadata.variant,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

final musicKindModule = LibraryKindSpec<MusicWorkspaceDto, MusicOwnedDetails>(
  presentation: musicLibraryMediaPresentation,
  searchTargetOptions: const [
    LibrarySearchTarget.all,
    LibrarySearchTarget.mediaOnly,
    LibrarySearchTarget.tracksOnly,
  ],
  trackingProfile: musicTrackingProfile,
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
    supportsServerCompare: true,
    providers: [musicBrainzMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    childrenTitleBuilder: _musicChildrenTitle,
    fetchChildrenCallback: _fetchMusicTracks,
    supportsMediaReleaseSplit: true,
  ),
  uiPolicy: const LibraryUiPolicy(
    coverAspectRatio: 1.0,
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<MusicCatalogMetadata>(
    _musicLinkedMetadataValues,
  ),
  transfer: const LibraryTransferCapability(),
  stats: const MusicStatsCapability(),
  add: StandardLibraryAddCapability<MusicAddDraft>(
    kind: CatalogMediaKind.music,
    initialDraftBuilder: MusicAddDraft.new,
    manualDraftBuilder: MusicAddManualDraft.new,
    search: LibraryAddSearchCapability(
      advancedFilterDescriptorsBuilder: buildMusicAddAdvancedFilterFields,
      coreSearchInputBuilder: _buildMusicCoreSearchInput,
      providerQueryBuilder: _buildMusicProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: _musicArtistFilterId,
            exactWeight: 120,
            containsWeight: 48,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is MusicCatalogMetadata
                  ? [metadata.artist]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.seriesTitle],
          ),
          LibraryAddSearchRankField(
            id: _musicLabelFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is MusicCatalogMetadata
                  ? [metadata.publisher, metadata.publishing?.imprint]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.publisher],
          ),
          LibraryAddSearchRankField(
            id: _musicYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is MusicCatalogMetadata
                  ? [
                      metadata.originalReleaseDate?.year,
                      metadata.recordingDate?.year,
                    ]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.volumeStartYear],
          ),
        ],
      ),
    ),
    manualPaneBuilder: buildMusicAddManualPane,
    chrome: _musicAddChrome,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildMusicLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(MusicVocabularies.all),
    presentation: musicLibraryEditPresentation,
    createDraft: createMusicEditDraft,
  ),
  providerMapper: const MusicLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildMusicCardPresentation,
);

String _musicChildrenTitle(int count) => 'Discs ($count)';

Future<List<LibraryHierarchyNode>> _fetchMusicTracks({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final dto =
      await api.getMusicReleaseDto(itemId).timeout(const Duration(seconds: 60));
  final release = MusicCoreMapper.fromReleaseDto(dto);
  return MusicHierarchyMapper.toLibraryNodes(release);
}

Map<String, dynamic> _encodeMusicMetadata(MusicCatalogMetadata m) => m.toJson();

List<LibraryAddAdvancedFilterField<String>> buildMusicAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: _musicArtistFilterId,
        key: const ValueKey('library-add-series-field'),
        label: 'Artist',
        value: req.advancedFilterText(_musicArtistFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _musicLabelFilterId,
        key: const ValueKey('library-add-label-field'),
        label: 'Record Label',
        value: req.advancedFilterText(_musicLabelFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _musicYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_musicYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

LibraryMetadataSearchInput _buildMusicCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return LibraryMetadataSearchInput(
    query: _optionalMusicText(context.query),
    series: _optionalMusicText(context.textValueFor(_musicArtistFilterId)),
    publisher: _optionalMusicText(context.textValueFor(_musicLabelFilterId)),
    year: int.tryParse(context.textValueFor(_musicYearFilterId)),
    barcode: _optionalMusicText(context.barcode),
    limit: limit,
  );
}

String _buildMusicProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_musicArtistFilterId),
    context.textValueFor(_musicLabelFilterId),
    context.textValueFor(_musicYearFilterId),
    context.barcode,
  ]);
}

String? _optionalMusicText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
