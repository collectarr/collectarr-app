import 'package:collectarr_app/core/models/catalog_media_kind.dart';

import 'package:collectarr_app/features/library/config/library_kind_toolbar_module.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/library_linked_metadata_capability.dart';
import 'package:collectarr_app/features/library/config/library_stats_capability.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/config/library_relation_capability.dart';
import 'package:collectarr_app/features/library/config/library_kind_identity.dart';
import 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
import 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
import 'package:collectarr_app/features/library/config/library_ui_policy.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';

export 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';

import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';

export 'package:collectarr_app/features/library/config/library_edit_capability.dart';
export 'package:collectarr_app/features/library/config/library_kind_identity.dart';
export 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
export 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
export 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
export 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
export 'package:collectarr_app/features/library/config/library_ui_policy.dart';
export 'package:collectarr_app/features/library/config/library_facet_types.dart';
export 'package:collectarr_app/features/library/config/library_stats_capability.dart';
export 'package:collectarr_app/features/library/config/library_value_capability.dart';
export 'package:collectarr_app/features/library/config/library_relation_capability.dart';
export 'package:collectarr_app/features/library/config/library_linked_metadata_capability.dart';
export 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
export 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
export 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';

/// Narrow identity boundary used by generic navigation and orchestration.
///
/// Semantic capabilities are deliberately not exposed here. They are
/// dispatched through the feature-specific generated maps below, so a generic
/// feature cannot accidentally treat this object as a semantic service
/// locator.
abstract interface class LibraryKindModule {
  CatalogMediaKind get kind;
  LibraryKindIdentity get identity;
}

class LibraryKindSpec<TDto extends LibraryWorkspaceDto>
    implements LibraryKindRegistration {
  const LibraryKindSpec({
    required this.add,
    required this.edit,
    required this.identity,
    required this.physicalMediaFormats,
    required this.metadata,
    required this.hierarchy,
    required this.inspector,
    required this.presentation,
    required this.trackingProfile,
    this.uiPolicy = const LibraryUiPolicy(),
    this.titleCapability = const DefaultTitleProjectionCapability(),
    this.releaseCapability,
    this.linkedMetadata = const DefaultLibraryLinkedMetadataCapability(),
    required this.transfer,
    this.stats = const DefaultLibraryStatsCapability(),
    this.value,
    this.relations,
    this.toolbar,
    this.searchTargetOptions = const [],
    LibraryWorkspaceViewProfile? viewProfile,
  }) : _viewProfile = viewProfile;

  @override
  final LibraryKindIdentity identity;

  final List<PhysicalMediaFormat> physicalMediaFormats;

  final LibraryMediaPresentation presentation;
  final LibraryMetadataCapability metadata;
  final LibraryHierarchyCapability hierarchy;
  final LibraryInspectorCapability inspector;
  final LibraryLinkedMetadataCapability linkedMetadata;
  final LibraryTransferCapability transfer;
  final LibraryStatsCapability stats;
  final LibraryValueCapability? value;
  final LibraryRelationCapability? relations;
  final LibraryEditCapability edit;
  final MediaTrackingProfile trackingProfile;
  final LibraryUiPolicy uiPolicy;
  final TitleProjectionCapability<LibraryWorkspaceDto> titleCapability;
  final ReleaseProjectionCapability<LibraryWorkspaceDto>? releaseCapability;

  LibraryAddChromeConfig get addChrome => add.chrome;

  @override
  CatalogMediaKind get kind => identity.kind;

  final LibraryWorkspaceViewProfile? _viewProfile;

  LibraryWorkspaceViewProfile get viewProfile =>
      _viewProfile ?? plannedMediaWorkspaceViewProfile(this);

  final LibraryAddCapability add;
  final LibraryKindToolbarModule? toolbar;
  final List<LibrarySearchTarget> searchTargetOptions;
}
