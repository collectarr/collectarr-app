import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/config/library_kind_toolbar_module.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_source.dart';

/// Feature-specific dispatch accessors for a concrete kind identity.
///
/// These accessors are backed by independent generated maps. Keeping them out
/// of [LibraryKindRegistration] prevents the identity/navigation boundary from
/// becoming a universal semantic service locator again.
extension LibraryKindRegistrationCapabilities on LibraryKindRegistration {
  List<PhysicalMediaFormat> get physicalMediaFormats =>
      collectarrKindPhysicalMediaFormats[kind]!;

  LibraryMediaPresentation get presentation =>
      collectarrKindPresentations[kind]!;

  LibraryMetadataCapability get metadata => collectarrKindMetadata[kind]!;

  MediaTrackingProfile get trackingProfile =>
      collectarrKindTrackingProfiles[kind]!;

  LibraryHierarchyCapability get hierarchy => collectarrKindHierarchies[kind]!;

  LibraryInspectorCapability get inspector => collectarrKindInspectors[kind]!;

  LibraryEditCapabilitySet get editCapabilities =>
      collectarrKindEditCapabilities[kind]!;

  LibraryEditPresentationCapability get editPresentation =>
      editCapabilities.presentationCapability;

  LibraryEditDraftCapability get editDraft => editCapabilities.draft;

  LibraryOwnedEditCapability get ownedEdit => editCapabilities.owned;

  LibraryTransferCapability get transfer => collectarrKindTransfers[kind]!;

  LibraryStatsCapability get stats => collectarrKindStats[kind]!;

  LibraryValueCapability? get value => collectarrKindValues[kind];

  LibraryRelationCapability? get relations => collectarrKindRelations[kind];

  LibraryUiPolicy get uiPolicy => collectarrKindUiPolicies[kind]!;

  LibraryLinkedMetadataCapability get linkedMetadata =>
      collectarrKindLinkedMetadata[kind]!;

  LibraryAddCapability get add => collectarrKindAdds[kind]!;

  LibraryAddChromeConfig get addChrome => add.chrome;

  TitleProjectionCapability<LibraryWorkspaceDto> get titleCapability =>
      collectarrKindTitleCapabilities[kind]!;

  ReleaseProjectionCapability<LibraryWorkspaceDto>? get releaseCapability =>
      collectarrKindReleaseCapabilities[kind];

  LibraryReleaseDetailSource? get releaseDetailSource =>
      collectarrKindReleaseDetailSources[kind];

  LibraryCatalogTargetCapability get catalogTarget =>
      collectarrKindCatalogTargets[kind]!;

  LibraryKindToolbarModule? get toolbar => collectarrKindToolbars[kind];

  List<LibrarySearchTarget> get searchTargetOptions =>
      collectarrKindSearchTargetOptions[kind] ?? const [];

  LibraryWorkspaceViewProfile get viewProfile =>
      collectarrKindViewProfiles[kind]!;
}
