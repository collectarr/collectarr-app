import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_group_mode_category.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_metadata_provider_models.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/library_type_capabilities.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
import 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
import 'package:collectarr_app/features/library/config/library_kind_identity.dart';
import 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
import 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
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
    return type.inspectorSectionsBuilder?.call(context, request) ?? const [];
  }

  bool supportsTrackSearch(LibraryTypeConfig type) {
    return type.workspaceBehavior.supportsTrackSearch;
  }

  bool showsReadingQueue(LibraryTypeConfig type) {
    return type.supportsReadingQueue;
  }

  bool supportsBucketManagement(
    LibraryTypeConfig type,
    String mode,
  ) {
    final groupDef =
        libraryKindRuntimeForType(type).fields.findGroupDefinition(mode);
    return groupDef?.supportsBucketManagement ?? false;
  }

  bool supportsMetadataCompareWithServer(LibraryTypeConfig type) {
    return type.supportsMetadataCompareWithServer;
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
    return type.browserModeForViewState(
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
    final groupDef = runtime.fields.findGroupDefinition(activeGroupMode);
    if (groupDef == null || !groupDef.supportsJump) {
      return false;
    }
    final issueSortNumber =
        type.workspaceBehavior.issueSortNumber ?? _issueSortNumber;
    return projection.allItems.any(
      (item) =>
          runtime.groupValue(item, groupDef.id) == selectedBucket &&
          issueSortNumber(item.dto.itemNumber) != null,
    );
  }

  bool shouldOpenReleaseFolderOnOpen(
    LibraryTypeConfig type, {
    required LibraryWorkspaceBrowserMode browserMode,
    required LibraryBrowserScope browseScope,
  }) {
    return type.shouldOpenReleaseFolderOnOpen(
      browserMode: browserMode,
      browseScope: browseScope,
    );
  }

  bool shouldShowReleaseFolderBack(
    LibraryTypeConfig type, {
    required LibraryWorkspaceBrowserMode browserMode,
    String? releaseFolderTitleItemId,
  }) {
    return type.shouldShowReleaseFolderBack(
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
    this.conditions = kGeneralConditions,
    this.grades = const [],
    this.defaultCondition,
    this.defaultGrade,
    this.capabilities = const LibraryTypeCapabilities(),
    this.workspaceBehavior = const LibraryKindWorkspaceBehavior(),
    this.presentation = genericLibraryMediaPresentation,
    this.addChrome = const LibraryAddChromeConfig(),
    this.editChrome = const LibraryEditChromeConfig(),
    this.addDialogLauncher,
    this.editDialogBuilder,
    this.mediaEditDialogBuilder,
    this.releaseEditDialogBuilder,
    this.detailPageBuilder,
    this.inspectorHeroBuilder,
    this.inspectorSectionsBuilder,
    this.showsDefaultInspectorPersonalSection = true,
    this.kindBrowserDelegateBuilder,
    this.kindUiAdapter = const LibraryKindUiAdapter(),
    this.titleCapability =
        const DefaultTitleProjectionCapability<LibraryWorkspaceDto>(),
    this.releaseCapability,
  });

  factory LibraryTypeConfig.fromCapabilities({
    required LibraryKindIdentity identity,
    LibraryMetadataCapability metadata = const LibraryMetadataCapability(
      defaultProviderId: '',
      providers: <LibraryMetadataProviderOption>[],
    ),
    LibraryHierarchyCapability hierarchy = const LibraryHierarchyCapability(),
    LibraryInspectorCapability inspector = const LibraryInspectorCapability(),
    LibraryEditCapability edit = const LibraryEditCapability(),
    LibraryTransferCapability transfer = const LibraryTransferCapability(),
    LibraryKindWorkspaceBehavior workspaceBehavior =
        const LibraryKindWorkspaceBehavior(),
    LibraryMediaPresentation presentation = genericLibraryMediaPresentation,
    MediaTrackingProfile trackingProfile = readingTrackingProfile,
    LibraryAddDialogLauncher? addDialogLauncher,
    LibraryKindBrowserDelegate Function()? kindBrowserDelegateBuilder,
    LibraryKindUiAdapter kindUiAdapter = const LibraryKindUiAdapter(),
    TitleProjectionCapability<LibraryWorkspaceDto> titleCapability =
        const DefaultTitleProjectionCapability<LibraryWorkspaceDto>(),
    ReleaseProjectionCapability<LibraryWorkspaceDto>? releaseCapability,
  }) {
    return LibraryTypeConfig(
      workspace: identity.toWorkspaceConfig(),
      singularLabel: identity.singularLabel,
      pluralLabel: identity.pluralLabel,
      defaultMetadataProvider: metadata.defaultProviderId,
      metadataProviders: metadata.providers,
      trackingProfile: trackingProfile,
      conditions: edit.conditions,
      grades: edit.grades,
      defaultCondition: edit.defaultCondition,
      defaultGrade: edit.defaultGrade,
      capabilities: LibraryTypeCapabilities(
        contentHierarchy: hierarchy.contentHierarchy,
        supportsSeriesSubgroups: hierarchy.supportsSeriesSubgroups,
        supportsMediaReleaseSplit: hierarchy.supportsMediaReleaseSplit,
        supportsIndexReassignment: hierarchy.supportsIndexReassignment,
        supportsMetadataCompareWithServer: metadata.supportsServerCompare,
        showsReadingQueue: hierarchy.showsReadingQueue,
      ),
      workspaceBehavior: workspaceBehavior,
      presentation: presentation,
      addChrome: const LibraryAddChromeConfig(),
      editChrome: edit.editChrome,
      addDialogLauncher: addDialogLauncher,
      editDialogBuilder: edit.editDialogBuilder,
      mediaEditDialogBuilder: edit.mediaEditDialogBuilder,
      releaseEditDialogBuilder: edit.releaseEditDialogBuilder,
      detailPageBuilder: inspector.detailPageBuilder,
      inspectorHeroBuilder: inspector.heroBuilder,
      inspectorSectionsBuilder: inspector.sectionsBuilder,
      showsDefaultInspectorPersonalSection:
          inspector.showsDefaultPersonalSection,
      kindBrowserDelegateBuilder: kindBrowserDelegateBuilder,
      kindUiAdapter: kindUiAdapter,
      titleCapability: titleCapability,
      releaseCapability: releaseCapability,
    );
  }

  final LibraryWorkspaceConfig workspace;
  final String singularLabel;
  final String pluralLabel;
  final String defaultMetadataProvider;
  final List<LibraryMetadataProviderOption> metadataProviders;
  final MediaTrackingProfile trackingProfile;

  final List<String> conditions;
  final List<String> grades;
  final String? defaultCondition;
  final String? defaultGrade;
  final LibraryTypeCapabilities capabilities;
  final LibraryKindWorkspaceBehavior workspaceBehavior;
  final LibraryMediaPresentation presentation;
  final LibraryAddChromeConfig addChrome;
  final LibraryEditChromeConfig editChrome;
  final LibraryAddDialogLauncher? addDialogLauncher;
  final LibraryEditDialogBuilder? editDialogBuilder;
  final LibraryEditDialogBuilder? mediaEditDialogBuilder;
  final LibraryEditDialogBuilder? releaseEditDialogBuilder;
  final LibraryDetailPageBuilder? detailPageBuilder;
  final LibraryInspectorHeroBuilder? inspectorHeroBuilder;
  final LibraryDetailSectionsBuilder? inspectorSectionsBuilder;

  final bool showsDefaultInspectorPersonalSection;
  final LibraryKindBrowserDelegate Function()? kindBrowserDelegateBuilder;
  final LibraryKindUiAdapter kindUiAdapter;
  final TitleProjectionCapability<LibraryWorkspaceDto> titleCapability;
  final ReleaseProjectionCapability<LibraryWorkspaceDto>? releaseCapability;

  List<String> transferableFieldKeysForScope(LibraryEditScope scope) {
    final module = libraryKindRuntimeForType(this);
    return module.transfer.fieldKeysForScope(scope);
  }

  List<TransferableField> transferableFieldsWithCustomFieldsForScope(
    List<CustomFieldDefinition> definitions,
    LibraryEditScope scope,
  ) {
    final module = libraryKindRuntimeForType(this);
    return module.transfer.fieldsWithCustomFields(definitions, scope);
  }

  List<String> get availableGroupModes {
    final module = libraryKindRuntimeForType(this);
    return [for (final definition in module.fields.groups) definition.id.value];
  }

  LibraryWorkspaceDensityPreset get defaultDensityPreset =>
      workspace.defaultDensityPreset;

  List<LibraryWorkspaceDensityPreset> get availableDensityPresets =>
      workspace.availableDensityPresets;

  String preferenceKey(String suffix) => workspace.preferenceKey(suffix);

  bool supportsDensityPreset(LibraryWorkspaceDensityPreset preset) {
    return workspace.availableDensityPresets.contains(preset);
  }

  bool get supportsReadingQueue => capabilities.showsReadingQueue;

  bool get supportsMediaReleaseSplit => capabilities.supportsMediaReleaseSplit;

  bool get supportsMetadataCompareWithServer =>
      capabilities.supportsMetadataCompareWithServer;

  bool get supportsIndexReassignment => capabilities.supportsIndexReassignment;

  bool get supportsSeriesIssueJump =>
      workspaceBehavior.supportsSeriesIssueJump ||
      presentation.supportsSeriesIssueJump;

  bool get hasConditionPickList => conditions.isNotEmpty;
  bool get hasGradePickList => grades.isNotEmpty;

  bool get supportsSeriesSubgroups => capabilities.supportsSeriesSubgroups;

  OwnedDetailsDraft buildPersonalOwnedDetailsDraft(
    LibraryPersonalEditSelection personal,
  ) {
    return kindUiAdapter.buildPersonalDetailsDraft(this, personal);
  }

  List<String> availableGroupModesForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    if (!capabilities.scopesOptionsByBrowserMode) {
      return availableGroupModes;
    }
    final scoped = browserMode == LibraryWorkspaceBrowserMode.releases
        ? capabilities.releaseScopeGroupIds
        : capabilities.mediaScopeGroupIds;
    if (scoped == null) {
      return availableGroupModes;
    }
    return [
      for (final mode in availableGroupModes)
        if (scoped.contains(mode)) mode,
    ];
  }

  List<String> availableSortColumnsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    final module = libraryKindRuntimeForType(this);
    final allSorts = [
      for (final def in module.fields.sorts) def.id.value,
    ];
    if (!capabilities.scopesOptionsByBrowserMode) {
      return allSorts;
    }
    final scoped = browserMode == LibraryWorkspaceBrowserMode.releases
        ? capabilities.releaseScopeSortIds
        : capabilities.mediaScopeSortIds;
    if (scoped == null) {
      return allSorts;
    }
    return [
      for (final column in allSorts)
        if (scoped.contains(column)) column,
    ];
  }

  LibraryWorkspaceBrowserMode browserModeForViewState(
    LibraryWorkspaceViewState viewState, {
    String? releaseFolderTitleItemId,
  }) {
    if (!supportsMediaReleaseSplit) {
      return LibraryWorkspaceBrowserMode.media;
    }
    if (releaseFolderTitleItemId != null) {
      return LibraryWorkspaceBrowserMode.releases;
    }
    return viewState.browserMode;
  }

  LibraryEditScope editScopeForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    return browserMode == LibraryWorkspaceBrowserMode.releases
        ? LibraryEditScope.release
        : LibraryEditScope.media;
  }

  bool shouldOpenReleaseFolderOnOpen({
    required LibraryWorkspaceBrowserMode browserMode,
    required LibraryBrowserScope browseScope,
  }) {
    return supportsMediaReleaseSplit &&
        browserMode == LibraryWorkspaceBrowserMode.media &&
        browseScope == LibraryBrowserScope.title;
  }

  bool shouldShowReleaseFolderBack({
    required LibraryWorkspaceBrowserMode browserMode,
    String? releaseFolderTitleItemId,
  }) {
    return supportsMediaReleaseSplit &&
        browserMode == LibraryWorkspaceBrowserMode.releases &&
        releaseFolderTitleItemId != null;
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
