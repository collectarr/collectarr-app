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

import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';

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

/// Typed capability surface used by generic navigation and orchestration.
///
/// Do not add members here. New dispatch contracts belong in
/// [LibraryKindRegistration] or in the concrete kind module that owns them.
abstract interface class LibraryKindModule {
  CatalogMediaKind get kind;
  LibraryKindIdentity get identity;
  List<PhysicalMediaFormat> get physicalMediaFormats;
  LibraryMediaPresentation get presentation;
  LibraryMetadataCapability get metadata;
  MediaTrackingProfile get trackingProfile;
  LibraryHierarchyCapability get hierarchy;
  LibraryInspectorCapability get inspector;
  LibraryEditCapability get edit;
  LibraryTransferCapability get transfer;
  LibraryStatsCapability get stats;
  LibraryValueCapability? get value;
  LibraryRelationCapability? get relations;
  LibraryUiPolicy get uiPolicy;
  LibraryLinkedMetadataCapability get linkedMetadata;
  LibraryAddCapability get add;
  LibraryAddChromeConfig get addChrome => add.chrome;
  TitleProjectionCapability<LibraryWorkspaceDto> get titleCapability;
  ReleaseProjectionCapability<LibraryWorkspaceDto>? get releaseCapability;
  LibraryKindToolbarModule? get toolbar;
  List<LibrarySearchTarget> get searchTargetOptions;

  LibraryWorkspaceViewProfile get viewProfile;
}

class LibraryKindSpec<TDto extends LibraryWorkspaceDto>
    implements LibraryKindModule {
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

  @override
  final List<PhysicalMediaFormat> physicalMediaFormats;

  @override
  final LibraryMediaPresentation presentation;
  @override
  final LibraryMetadataCapability metadata;
  @override
  final LibraryHierarchyCapability hierarchy;
  @override
  final LibraryInspectorCapability inspector;
  @override
  final LibraryLinkedMetadataCapability linkedMetadata;
  @override
  final LibraryTransferCapability transfer;
  @override
  final LibraryStatsCapability stats;
  @override
  final LibraryValueCapability? value;
  @override
  final LibraryRelationCapability? relations;
  @override
  final LibraryEditCapability edit;
  @override
  final MediaTrackingProfile trackingProfile;
  @override
  final LibraryUiPolicy uiPolicy;
  @override
  final TitleProjectionCapability<LibraryWorkspaceDto> titleCapability;
  @override
  final ReleaseProjectionCapability<LibraryWorkspaceDto>? releaseCapability;

  @override
  LibraryAddChromeConfig get addChrome => add.chrome;

  @override
  CatalogMediaKind get kind => identity.kind;

  final LibraryWorkspaceViewProfile? _viewProfile;

  @override
  LibraryWorkspaceViewProfile get viewProfile =>
      _viewProfile ?? plannedMediaWorkspaceViewProfile(this);

  @override
  final LibraryAddCapability add;
  @override
  final LibraryKindToolbarModule? toolbar;
  @override
  final List<LibrarySearchTarget> searchTargetOptions;
}
