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

/// Internal composition bundle for one kind's feature capabilities.
///
/// This is not a runtime registration and is never returned by the public
/// registry. The generated feature maps read these concrete bundles at the
/// composition root, while application code receives only a registration or
/// a feature-specific capability.
class LibraryKindCapabilityBundle<TDto extends LibraryWorkspaceDto> {
  const LibraryKindCapabilityBundle({
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

  final LibraryWorkspaceViewProfile? _viewProfile;

  LibraryWorkspaceViewProfile get viewProfile =>
      _viewProfile ??
      standardMediaWorkspaceViewProfile(identity.kind, uiPolicy);

  final LibraryAddCapability add;
  final LibraryKindToolbarModule? toolbar;
  final List<LibrarySearchTarget> searchTargetOptions;
}
