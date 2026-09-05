import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/generic/add/generic_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/generic/add/generic_add_manual_draft.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/generic/add/generic_add_draft.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/kinds/generic/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/generic/edit/generic_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/generic/workspace/generic_fields.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:flutter/material.dart';

final genericKindModule =
    LibraryKindSpec<GenericWorkspaceDto, GenericOwnedDetails>(
  presentation: genericLibraryMediaPresentation,
  trackingProfile: readingTrackingProfile,
  projector: const GenericWorkspaceProjector(),
  ownedDetailsCodec: const GenericOwnedDetailsCodec(),
  fields: genericLibraryKindSchema.toRegistry(),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.unknown,
    singularLabel: 'Item',
    pluralLabel: 'Items',
    title: 'Generic',
    icon: Icons.category_outlined,
    accent: kLibraryFallbackAccent,
    preferencePrefix: 'generic',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: '',
    providers: [],
  ),
  hierarchy: const LibraryHierarchyCapability(),
  inspector: const LibraryInspectorCapability(),
  transfer: const LibraryTransferCapability(),
  add: StandardLibraryAddCapability<GenericAddDraft>(
    kind: CatalogMediaKind.unknown,
    initialDraftBuilder: GenericAddDraft.new,
    manualDraftBuilder: GenericAddManualDraft.new,
    search: LibraryAddSearchCapability(
      advancedFilterDescriptorsBuilder: buildGenericAddAdvancedFilterFields,
      coreSearchInputBuilder: _buildGenericCoreSearchInput,
      providerQueryBuilder: _buildGenericProviderQuery,
      ranking: buildLibraryAddSearchRanking(fields: const []),
    ),
    manualPaneBuilder: buildGenericAddManualPane,
  ),
  edit: LibraryEditCapability(
    presentation: genericLibraryEditPresentation,
    createDraft: createGenericEditDraft,
  ),
  buildCardPresentation: (item, {required musicVertical}) =>
      const LibraryCardPresentation(),
);

List<LibraryAddAdvancedFilterField<String>> buildGenericAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    const [];

LibraryMetadataSearchInput _buildGenericCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  final query = context.query.trim();
  final barcode = context.barcode.trim();
  return LibraryMetadataSearchInput(
    query: query.isEmpty ? null : query,
    barcode: barcode.isEmpty ? null : barcode,
    limit: limit,
  );
}

String _buildGenericProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([context.query, context.barcode]);
}
