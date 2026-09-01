import 'package:collectarr_app/features/library/config/library_group_mode_category.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_metadata_provider_models.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/config/library_chrome_config.dart';
export 'package:collectarr_app/features/library/config/library_edit_capability.dart';
export 'package:collectarr_app/features/library/config/library_group_mode_category.dart';
export 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
export 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
export 'package:collectarr_app/features/library/config/library_item_actions.dart';
export 'package:collectarr_app/features/library/config/library_kind_identity.dart';
export 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
export 'package:collectarr_app/features/library/config/library_metadata_provider_models.dart';
export 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
export 'package:collectarr_app/features/library/config/library_type_capabilities.dart';

class LibraryKindUiAdapter {
  const LibraryKindUiAdapter();

  List<LibraryEditTabSpec> detailTabs(
    LibraryTypeConfig type, {
    required LibraryEditPresentationContext context,
  }) {
    return libraryKindRuntimeForType(type)
        .edit
        .presentation
        .builderForScope(context.scope)
        .buildTabs(context: context);
  }

  List<Widget> inspectorSections(
    LibraryTypeConfig type, {
    required BuildContext context,
    required LibraryInspectorRequest request,
  }) {
    return libraryKindRuntimeForType(type)
        .inspector
        .buildSections(context, request);
  }

  bool supportsTrackSearch(LibraryTypeConfig type) {
    return type.presentation.supportsTrackSearch;
  }

  bool showsReadingQueue(LibraryTypeConfig type) {
    return libraryKindRuntimeForType(type).hierarchy.showsReadingQueue;
  }

  bool supportsBucketManagement(
    LibraryTypeConfig type,
    String mode,
  ) {
    final fields = libraryKindRuntimeForType(type).fields;
    final groupDef = fields.findGroupDefinition(fields.decodeGroupId(mode));
    return groupDef?.supportsBucketManagement ?? false;
  }

  bool supportsMetadataCompareWithServer(LibraryTypeConfig type) {
    return libraryKindRuntimeForType(type).metadata.supportsServerCompare;
  }

  OwnedDetailsDraft buildPersonalDetailsDraft(
    LibraryTypeConfig type,
    LibraryPersonalEditSelection personal,
  ) {
    return libraryKindRuntimeForType(type).buildPersonalDetailsDraft(personal);
  }

  LibraryWorkspaceBrowserMode browserModeForViewState(
    LibraryTypeConfig type,
    LibraryWorkspaceViewState viewState, {
    String? releaseFolderTitleItemId,
  }) {
    return libraryKindRuntimeForType(type).hierarchy.browserModeForViewState(
          viewState,
          releaseFolderTitleItemId: releaseFolderTitleItemId,
        );
  }

  String? releaseFolderLabelForProjection(
    LibraryTypeConfig type,
    LibraryProjection? projection, {
    String? releaseFolderTitleItemId,
  }) {
    final titleId = releaseFolderTitleItemId;
    if (titleId == null || projection == null) {
      return null;
    }
    for (final item in projection.allItems) {
      if (item.node.titleItemId == titleId) {
        return item.dto.title;
      }
    }
    return null;
  }

  bool canJumpToSelectedEntry(
    LibraryTypeConfig type,
    LibraryProjection? projection, {
    required String activeGroupMode,
    required String? selectedBucket,
  }) {
    if (projection == null || selectedBucket == null) {
      return false;
    }
    final runtime = libraryKindRuntimeForType(type);
    final groupDef = runtime.fields.findGroupDefinition(
      runtime.fields.decodeGroupId(activeGroupMode),
    );
    if (groupDef == null || !groupDef.supportsJump) {
      return false;
    }
    final issueSortNumber = _issueSortNumber;
    return projection.allItems.any(
      (item) {
        final adapter = item.dto is WorkspaceDtoAdapter
            ? item.dto as WorkspaceDtoAdapter
            : null;
        return runtime.groupValue(item, groupDef.id) == selectedBucket &&
            issueSortNumber(adapter?.itemNumber) != null;
      },
    );
  }

  bool shouldOpenReleaseFolderOnOpen(
    LibraryTypeConfig type, {
    required LibraryWorkspaceBrowserMode browserMode,
    required LibraryBrowserScope browseScope,
  }) {
    return libraryKindRuntimeForType(type)
        .hierarchy
        .shouldOpenReleaseFolderOnOpen(
          browserMode: browserMode,
          browseScope: browseScope,
        );
  }

  bool shouldShowReleaseFolderBack(
    LibraryTypeConfig type, {
    required LibraryWorkspaceBrowserMode browserMode,
    String? releaseFolderTitleItemId,
  }) {
    return libraryKindRuntimeForType(type)
        .hierarchy
        .shouldShowReleaseFolderBack(
          browserMode: browserMode,
          releaseFolderTitleItemId: releaseFolderTitleItemId,
        );
  }

  List<LibraryGroupModeCategory> groupModeCategories(
    LibraryTypeConfig type,
    List<String> modes,
  ) {
    final builder = type.capabilities.groupModeCategoriesBuilder;
    if (builder != null) {
      return builder(modes);
    }
    return defaultLibraryGroupModeCategories(type, modes);
  }

  List<LibraryGroupModeCategory> sidebarFacets(
    LibraryTypeConfig type,
    List<String> modes,
  ) {
    return groupModeCategories(type, modes);
  }
}

int? _issueSortNumber(String? raw) {
  if (raw == null) {
    return null;
  }
  return int.tryParse(raw.trim());
}

class LibraryTypeConfig {
  const LibraryTypeConfig({
    required this.workspace,
    required this.singularLabel,
    required this.pluralLabel,
    required this.defaultMetadataProvider,
    required this.metadataProviders,
    required this.trackingProfile,
    this.capabilities = const LibraryTypeCapabilities(),
    this.presentation = genericLibraryMediaPresentation,
    this.addChrome = const LibraryAddChromeConfig(),
    this.kindUiAdapter = const LibraryKindUiAdapter(),
    this.titleCapability =
        const DefaultTitleProjectionCapability<LibraryWorkspaceDto>(),
    this.releaseCapability,
  });

  final LibraryWorkspaceConfig workspace;
  final String singularLabel;
  final String pluralLabel;
  final String defaultMetadataProvider;
  final List<LibraryMetadataProviderOption> metadataProviders;
  final MediaTrackingProfile trackingProfile;

  final LibraryTypeCapabilities capabilities;
  LibraryUiPolicy get uiPolicy => capabilities.uiPolicy;
  final LibraryMediaPresentation presentation;
  final LibraryAddChromeConfig addChrome;
  final LibraryKindUiAdapter kindUiAdapter;
  final TitleProjectionCapability<LibraryWorkspaceDto> titleCapability;
  final ReleaseProjectionCapability<LibraryWorkspaceDto>? releaseCapability;

  LibraryWorkspaceDensityPreset get defaultDensityPreset =>
      workspace.defaultDensityPreset;

  List<LibraryWorkspaceDensityPreset> get availableDensityPresets =>
      workspace.availableDensityPresets;

  String preferenceKey(String suffix) => workspace.preferenceKey(suffix);

  bool supportsDensityPreset(LibraryWorkspaceDensityPreset preset) {
    return workspace.availableDensityPresets.contains(preset);
  }

  OwnedDetailsDraft buildPersonalOwnedDetailsDraft(
    LibraryPersonalEditSelection personal,
  ) {
    return kindUiAdapter.buildPersonalDetailsDraft(this, personal);
  }

  List<LibraryMetadataProviderOption> get supportedMetadataProviders {
    if (workspace.kind.isUnknown) {
      return metadataProviders;
    }
    return [
      for (final provider in metadataProviders)
        if (provider.supportsKind(workspace.kind)) provider,
    ];
  }

  String get defaultSupportedMetadataProvider {
    return defaultSupportedMetadataProviderOption?.id ??
        defaultMetadataProvider;
  }

  LibraryMetadataProviderOption? get defaultSupportedMetadataProviderOption {
    final options = supportedMetadataProviders;
    for (final option in options) {
      if (option.id == defaultMetadataProvider) {
        return option;
      }
    }
    return options.isEmpty ? null : options.first;
  }

  LibraryMetadataProviderOption? get defaultMetadataProviderOption {
    for (final option in supportedMetadataProviders) {
      if (option.id == defaultMetadataProvider) {
        return option;
      }
    }
    return null;
  }

  bool supportsMetadataProvider(String providerId) {
    return supportedMetadataProviders.any((option) => option.id == providerId);
  }

  String countLabel(int count) {
    return count == 1 ? singularLabel : pluralLabel;
  }

  String metadataProviderLabel(String providerId) {
    for (final option in metadataProviders) {
      if (option.id == providerId) {
        return option.label;
      }
    }
    return providerId;
  }
}
