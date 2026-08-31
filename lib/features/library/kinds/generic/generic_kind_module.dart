import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/generic/add/generic_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/generic/add/generic_add_manual_draft.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/generic/add/generic_add_draft.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/generic/workspace/generic_fields.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

final genericLibraryConfig = LibraryTypeConfig(
  workspace: const LibraryWorkspaceConfig(
    kind: CatalogMediaKind.unknown,
    title: 'Generic',
    icon: Icons.category_outlined,
    accent: kLibraryFallbackAccent,
    preferencePrefix: 'generic',
  ),
  singularLabel: 'Item',
  pluralLabel: 'Items',
  defaultMetadataProvider: '',
  metadataProviders: const [],
  trackingProfile: readingTrackingProfile,
  presentation: genericLibraryMediaPresentation,
);

final genericKindModule =
    LibraryKindSpec<GenericWorkspaceDto, GenericOwnedDetails>(
  type: genericLibraryConfig,
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
  add: const StandardLibraryAddCapability<GenericAddDraft>(
    kind: CatalogMediaKind.unknown,
    initialDraftBuilder: GenericAddDraft.new,
    manualDraftBuilder: GenericAddManualDraft.new,
    advancedFilterFieldsBuilder: buildGenericAddAdvancedFilterFields,
    manualPaneBuilder: buildGenericAddManualPane,
  ),
  edit: const LibraryEditCapability(),
  buildCardPresentation: (item, {required musicVertical}) =>
      const LibraryCardPresentation(),
);

List<LibraryAddAdvancedFilterField> buildGenericAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField(
        key: const ValueKey('library-add-series-field'),
        label: 'Series / Group',
        controller: req.seriesController,
      ),
      LibraryAddAdvancedFilterField(
        key: const ValueKey('library-add-publisher-field'),
        label: 'Publisher / Brand',
        controller: req.publisherController,
      ),
      LibraryAddAdvancedFilterField(
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        controller: req.yearController,
        width: 120,
      ),
    ];
