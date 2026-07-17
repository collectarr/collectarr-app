import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';

typedef LibraryGroupModeCategoryBuilder = List<LibraryGroupModeCategory>
    Function(
  List<Object> modes,
);

const kTransferableMediaFieldKeys = <String>[];

const kTransferableReleaseFieldKeys = <String>[
  'features',
  'boxSetName',
  'coverPriceCents',
];

const kTransferablePersonalFieldKeys = <String>[
  'condition',
  'grade',
  'personalNotes',
  'locationId',
  'tags',
  'currency',
  'readStatus',
  'soldTo',
  'purchaseStore',
  'pricePaidCents',
  'sellPriceCents',
  'quantity',
  'indexNumber',
  'rating',
  'purchaseDate',
  'startedAt',
  'finishedAt',
  'soldAt',
];

const kDefaultTransferableFieldKeys = <String>[
  ...kTransferableReleaseFieldKeys,
  ...kTransferablePersonalFieldKeys,
];

const kComicTransferableFieldKeys = [
  'rawOrSlabbed',
  'gradingCompany',
  'graderNotes',
  'signedBy',
  'keyReason',
  'keyComic',
];

class LibraryAddDialogRequest {
  const LibraryAddDialogRequest({
    required this.type,
    this.accent,
    this.initialQuery,
    this.initialBarcode,
  });

  final LibraryTypeConfig type;
  final Color? accent;
  final String? initialQuery;
  final String? initialBarcode;
}

class LibraryAddDialogResult {
  const LibraryAddDialogResult({
    required this.target,
    required this.itemIds,
  });

  final LibraryAddTarget target;
  final List<String> itemIds;
}

typedef LibraryAddDialogLauncher = Future<LibraryAddDialogResult?> Function(
  BuildContext context,
  LibraryAddDialogRequest request,
);

class LibraryEditDialogRequest {
  const LibraryEditDialogRequest({
    required this.type,
    required this.item,
    required this.ownedItem,
    required this.accent,
    this.scope,
    this.wishlistItem,
    this.trackingEntry,
    this.availableBundleReleases = const [],
    this.physicalFormats = const [],
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
    this.onPrevious,
    this.onNext,
    this.openMetadataCompareOnOpen = false,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final OwnedItem? ownedItem;
  final Color accent;
  final LibraryEditScope? scope;

  LibraryEditScope get resolvedScope {
    final explicitScope = scope;
    if (explicitScope != null) {
      return explicitScope;
    }
    return ownedItem != null || trackingEntry != null || wishlistItem != null
        ? LibraryEditScope.all
        : LibraryEditScope.media;
  }

  final WishlistItem? wishlistItem;
  final TrackingEntry? trackingEntry;
  final List<BundleReleaseSummary> availableBundleReleases;
  final List<PhysicalMediaFormat> physicalFormats;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool openMetadataCompareOnOpen;

  LibraryEditDialogRequest copyWith({
    LibraryTypeConfig? type,
    LibraryMetadataItem? item,
    OwnedItem? ownedItem,
    Color? accent,
    LibraryEditScope? scope,
    WishlistItem? wishlistItem,
    TrackingEntry? trackingEntry,
    List<BundleReleaseSummary>? availableBundleReleases,
    List<PhysicalMediaFormat>? physicalFormats,
    List<CustomFieldDefinition>? customFieldDefinitions,
    List<CustomFieldValue>? customFieldValues,
    List<ItemImage>? itemImages,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
    bool? openMetadataCompareOnOpen,
  }) {
    return LibraryEditDialogRequest(
      type: type ?? this.type,
      item: item ?? this.item,
      ownedItem: ownedItem ?? this.ownedItem,
      accent: accent ?? this.accent,
      scope: scope ?? this.scope,
      wishlistItem: wishlistItem ?? this.wishlistItem,
      trackingEntry: trackingEntry ?? this.trackingEntry,
      availableBundleReleases:
          availableBundleReleases ?? this.availableBundleReleases,
      physicalFormats: physicalFormats ?? this.physicalFormats,
      customFieldDefinitions:
          customFieldDefinitions ?? this.customFieldDefinitions,
      customFieldValues: customFieldValues ?? this.customFieldValues,
      itemImages: itemImages ?? this.itemImages,
      onPrevious: onPrevious ?? this.onPrevious,
      onNext: onNext ?? this.onNext,
      openMetadataCompareOnOpen:
          openMetadataCompareOnOpen ?? this.openMetadataCompareOnOpen,
    );
  }
}

typedef LibraryEditDialogBuilder = Widget Function(
  BuildContext context,
  LibraryEditDialogRequest request,
);

class LibraryDetailPageRequest {
  const LibraryDetailPageRequest({
    required this.type,
    required this.entry,
    required this.ownedItem,
    required this.accent,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(OwnedItem? ownedItem)? onEdit;
  final ValueChanged<String>? onFilterByValue;
}

typedef LibraryDetailPageBuilder = Widget Function(
  BuildContext context,
  LibraryDetailPageRequest request,
);

class LibraryInspectorRequest {
  const LibraryInspectorRequest({
    required this.type,
    required this.entry,
    required this.ownedItem,
    this.onEdit,
    this.ownedCopies = const [],
    required this.trackingEntry,
    required this.accent,
    this.detailsLayout = LibraryDetailsLayout.hidden,
    this.onFilterByValue,
    this.searchQuery,
    this.searchTarget = LibrarySearchTarget.all,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final VoidCallback? onEdit;
  final List<OwnedItem> ownedCopies;
  final TrackingEntry? trackingEntry;
  final Color accent;
  final LibraryDetailsLayout detailsLayout;
  final ValueChanged<String>? onFilterByValue;
  final String? searchQuery;
  final LibrarySearchTarget searchTarget;
}

typedef LibraryDetailSectionsBuilder = List<Widget> Function(
  BuildContext context,
  LibraryInspectorRequest request,
);

typedef LibraryInspectorHeroBuilder = Widget Function(
  BuildContext context,
  LibraryInspectorRequest request,
);

class LibraryInspectorPanelRequest {
  const LibraryInspectorPanelRequest({
    required this.inspector,
    required this.hero,
    required this.primarySections,
    required this.trailingSections,
    required this.ownedCopies,
    required this.selectedOwnedItemId,
    required this.extraActions,
    required this.onAddCopy,
    required this.onOpenDetails,
    this.onDetailsLayoutChanged,
    this.ownedCopiesSection,
    this.bundleSection,
    this.conditionGradeSection,
    this.onSelectOwnedItem,
    this.onToggleOwned,
    this.onToggleWishlist,
    this.onEdit,
    this.onCorrectMetadata,
    this.onDuplicate,
    this.onLoan,
    this.onRefreshMetadata,
    this.onShare,
    this.onUnlinkFromCore,
  });

  final LibraryInspectorRequest inspector;
  final Widget hero;
  final List<Widget> primarySections;
  final List<Widget> trailingSections;
  final List<OwnedItem> ownedCopies;
  final String? selectedOwnedItemId;
  final List<Widget> extraActions;
  final VoidCallback onAddCopy;
  final VoidCallback onOpenDetails;
  final ValueChanged<LibraryDetailsLayout>? onDetailsLayoutChanged;
  final Widget? ownedCopiesSection;
  final Widget? bundleSection;
  final Widget? conditionGradeSection;
  final ValueChanged<String>? onSelectOwnedItem;
  final VoidCallback? onToggleOwned;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onEdit;
  final VoidCallback? onCorrectMetadata;
  final VoidCallback? onDuplicate;
  final VoidCallback? onLoan;
  final VoidCallback? onRefreshMetadata;
  final VoidCallback? onShare;
  final VoidCallback? onUnlinkFromCore;
}

class LibraryMetadataProviderOption {
  const LibraryMetadataProviderOption({
    required this.id,
    required this.label,
    this.description,
    this.supportedKinds = const {},
    this.requiresApiKey = false,
    this.usagePolicy,
  });

  final String id;
  final String label;
  final String? description;
  final Set<String> supportedKinds;
  final bool requiresApiKey;
  final LibraryMetadataProviderUsagePolicy? usagePolicy;

  bool supportsKind(Object? kind) {
    final normalized = switch (kind) {
      String value => value.trim().toLowerCase(),
      null => '',
      Object? _ => catalogMediaKindFromValue(kind).apiValue,
    };
    return supportedKinds.isEmpty || supportedKinds.contains(normalized);
  }
}

class LibraryMetadataProviderUsagePolicy {
  const LibraryMetadataProviderUsagePolicy({
    required this.summary,
    this.requiresAttribution = false,
    this.nonCommercialOnly = false,
  });

  final String summary;
  final bool requiresAttribution;
  final bool nonCommercialOnly;
}

enum LibraryContentHierarchy {
  flat,
  volumes,
  seasons,
}

class LibraryTypeCapabilities {
  const LibraryTypeCapabilities({
    this.showsSynopsis = false,
    this.showsTrackData = false,
    this.showsCreatorSpotlight = false,
    this.contentHierarchy = LibraryContentHierarchy.flat,
    this.canScanCover = false,
    this.supportsOwnedItemImages = true,
    this.supportsMediaReleaseSplit = false,
    this.supportsReadingQueue = false,
    this.supportsIndexReassignment = false,
    this.wideDialog = false,
    this.mediaScopeGroupModes,
    this.releaseScopeGroupModes,
    this.mediaScopeSortColumns,
    this.releaseScopeSortColumns,
    this.supportsMetadataCompare = false,
    this.prefersSquareCovers = false,
    this.groupModeCategoriesBuilder,
  });

  final bool showsSynopsis;
  final bool showsTrackData;
  final bool showsCreatorSpotlight;
  final LibraryContentHierarchy contentHierarchy;
  final bool canScanCover;
  final bool supportsOwnedItemImages;
  final bool supportsMediaReleaseSplit;
  final bool supportsReadingQueue;
  final bool supportsIndexReassignment;
  final bool wideDialog;

  /// Group modes and sort columns available when a media/release split library
  /// is showing the media scope vs the releases scope. When provided, the
  /// generic page narrows the available options per browser mode instead of
  /// hardcoding a per-kind rule.
  final Set<Object>? mediaScopeGroupModes;
  final Set<Object>? releaseScopeGroupModes;
  final Set<Object>? mediaScopeSortColumns;
  final Set<Object>? releaseScopeSortColumns;

  /// Whether this type can compare its local metadata against the canonical
  /// server record (e.g. comics and music).
  final bool supportsMetadataCompare;

  /// Whether this type's covers are square (e.g. music albums) and the grid
  /// should use square-tile sizing.
  final bool prefersSquareCovers;
  final LibraryGroupModeCategoryBuilder? groupModeCategoriesBuilder;

  /// Whether this type narrows group modes / sort columns by browser mode
  /// (media vs releases). Driven entirely by the scoped sets above.
  bool get scopesOptionsByBrowserMode =>
      mediaScopeGroupModes != null ||
      releaseScopeGroupModes != null ||
      mediaScopeSortColumns != null ||
      releaseScopeSortColumns != null;

  bool get usesSeasonHierarchy =>
      contentHierarchy == LibraryContentHierarchy.seasons;

  bool get usesVolumeHierarchy =>
      contentHierarchy == LibraryContentHierarchy.volumes;
}

class LibraryEditChromeConfig {
  const LibraryEditChromeConfig({
    this.titleUsesItemTitle = false,
    this.synopsisLabel = 'Synopsis',
    this.showsIssueBadge = false,
    this.showsPhysicalFormatBadge = false,
  });

  final bool titleUsesItemTitle;
  final String synopsisLabel;
  final bool showsIssueBadge;
  final bool showsPhysicalFormatBadge;
}

class LibraryAddChromeConfig {
  const LibraryAddChromeConfig({
    this.mediaReferenceLabel = 'Media',
    this.trackScopeSummary =
        'Tracking stays item-centric here. Edition and bundle scope are only available for owned or wishlist entries.',
    this.mediaReferenceHelperLabel = 'Track or save the canonical item itself.',
    this.editionReferenceHelperLabel =
        'Attach ownership to a specific edition. Pick a variant only if you want one exact physical version.',
    this.videoKindFilterOptions = const [],
    this.defaultVideoKindFilters = const {},
  });

  final String mediaReferenceLabel;
  final String trackScopeSummary;
  final String mediaReferenceHelperLabel;
  final String editionReferenceHelperLabel;
  final List<LibraryAddVideoKindFilterOption> videoKindFilterOptions;
  final Set<String> defaultVideoKindFilters;
}

class LibraryAddVideoKindFilterOption {
  const LibraryAddVideoKindFilterOption({
    required this.kind,
    required this.label,
    required this.icon,
  });

  final String kind;
  final String label;
  final IconData icon;
}

class LibraryGroupModeCategory {
  const LibraryGroupModeCategory(this.label, this.modes);

  final String label;
  final List<Object> modes;
}

class LibraryKindUiAdapter {
  const LibraryKindUiAdapter();

  List<LibraryEditTabSpec> detailTabs(
    LibraryTypeConfig type, {
    required LibraryEditPresentationContext context,
  }) {
    return type.editPresentation
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
    Object mode,
  ) {
    final modeId = type._definitionIdFor(mode);
    final groupDef = libraryKindModuleForType(type)
        .fields
        .groupDefinitionForId(modeId);
    return groupDef?.supportsBucketManagement ?? false;
  }

  bool supportsMetadataCompareWithServer(LibraryTypeConfig type) {
    return type.supportsMetadataCompareWithServer;
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
      if ((item.entry.titleItemId ?? item.entry.id) == titleId) {
        return item.entry.resolvedTitle;
      }
    }
    return null;
  }

  bool canJumpToSelectedEntry(
    LibraryTypeConfig type,
    LibraryProjection? projection, {
    required Object activeGroupMode,
    required String? selectedBucket,
  }) {
    if (projection == null ||
        activeGroupMode != 'series' ||
        selectedBucket == null) {
      return false;
    }
    final issueSortNumber =
        type.workspaceBehavior.issueSortNumber ?? _issueSortNumber;
    return projection.allItems.any(
      (item) =>
          genericBucketForItemMode(item, type, 'series') ==
              selectedBucket &&
          issueSortNumber(item.entry.itemNumber) != null,
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
    List<Object> modes,
  ) {
    final builder = type.capabilities.groupModeCategoriesBuilder;
    if (builder != null) {
      return builder(modes);
    }
    return _defaultGroupModeCategories(modes);
  }

  List<LibraryGroupModeCategory> sidebarFacets(
    LibraryTypeConfig type,
    List<Object> modes,
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

List<LibraryGroupModeCategory> _defaultGroupModeCategories(
  List<Object> modes,
) {
  String modeId(Object mode) {
    final str = mode is Enum ? mode.name : mode.toString();
    final normalized = str.contains('.') ? str.split('.').last : str;
    return normalized
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]}_${match[2]}',
        )
        .toLowerCase();
  }

  const mainModes = {
    'series',
    'story_arc',
    'character',
    'title',
    'publisher',
    'year',
    'audience_rating',
    'color',
    'genre',
    'country',
    'language',
    'age_rating',
    'movie_or_tv_series',
    'release_date',
    'release_month',
    'release_year',
  };
  const editionModes = {
    'audio_tracks',
    'box_set',
    'distributor',
    'edition_release_date',
    'edition_release_month',
    'edition_release_year',
    'extras',
    'format',
    'hdr',
    'layers',
    'packaging',
    'regions',
    'screen_ratios',
    'subtitles',
  };
  const crewModes = {
    'actor',
    'director',
    'musician',
    'photography',
    'producer',
    'writer',
    'creator',
    'artist',
    'penciller',
    'colorist',
    'letterer',
    'cover_artist',
    'editor',
  };
  final main = modes.where((mode) => mainModes.contains(modeId(mode))).toList();
  final edition = modes.where((mode) => editionModes.contains(modeId(mode))).toList();
  final crew = modes.where((mode) => crewModes.contains(modeId(mode))).toList();
  final personal = modes
      .where((mode) =>
          !mainModes.contains(modeId(mode)) &&
          !editionModes.contains(modeId(mode)) &&
          !crewModes.contains(modeId(mode)))
      .toList();
  return [
    if (main.isNotEmpty) LibraryGroupModeCategory('Main', main),
    if (edition.isNotEmpty) LibraryGroupModeCategory('Edition', edition),
    if (crew.isNotEmpty) LibraryGroupModeCategory('Cast & Crew', crew),
    if (personal.isNotEmpty) LibraryGroupModeCategory('Personal', personal),
  ];
}

class LibraryTypeConfig {
  const LibraryTypeConfig({
    required this.workspace,
    required this.singularLabel,
    required this.pluralLabel,
    required this.defaultMetadataProvider,
    required this.metadataProviders,
    required this.trackingProfile,
    required this.defaultSortColumn,
    required this.defaultVisibleColumns,
    required this.availableSortColumns,
    required this.availableSortColumnDefinitions,
    required this.availableTableColumns,
    this.conditions = kGeneralConditions,
    this.grades = const [],
    this.defaultCondition,
    this.defaultGrade,
    this.capabilities = const LibraryTypeCapabilities(),
    this.workspaceBehavior = const LibraryKindWorkspaceBehavior(),
    this.presentation = genericLibraryMediaPresentation,
    this.editPresentation = const LibraryEditPresentation(
        builder: DefaultLibraryEditPresentationBuilder()),
    this.addChrome = const LibraryAddChromeConfig(),
    this.editChrome = const LibraryEditChromeConfig(),
    this.mediaFields = const MediaEditFields(),
    this.releaseFields = const ReleaseEditFields(),
    this.collectionExportTitleLabel = 'Title',
    this.mediaReleaseScopeLabel = 'Media',
    this.manualAddUsesTitleAsSeries = false,
    this.editUsesTitleAsSeries = false,
    this.transferableFieldKeys = kDefaultTransferableFieldKeys,
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
  });

  final LibraryWorkspaceConfig workspace;
  final String singularLabel;
  final String pluralLabel;
  final String defaultMetadataProvider;
  final List<LibraryMetadataProviderOption> metadataProviders;
  final MediaTrackingProfile trackingProfile;
  final String defaultSortColumn;
  final Set<String> defaultVisibleColumns;
  final List<String> availableSortColumns;
  final List<LibrarySortDefinition<LibraryWorkspaceEntry>> availableSortColumnDefinitions;
  final List<String> availableTableColumns;
  final List<String> conditions;
  final List<String> grades;
  final String? defaultCondition;
  final String? defaultGrade;
  final LibraryTypeCapabilities capabilities;
  final LibraryKindWorkspaceBehavior workspaceBehavior;
  final LibraryMediaPresentation presentation;
  final LibraryEditPresentation editPresentation;
  final LibraryAddChromeConfig addChrome;
  final LibraryEditChromeConfig editChrome;
  final MediaEditFields mediaFields;
  final ReleaseEditFields releaseFields;
  final String collectionExportTitleLabel;
  final String mediaReleaseScopeLabel;
  final bool manualAddUsesTitleAsSeries;
  final bool editUsesTitleAsSeries;
  final List<String> transferableFieldKeys;
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

  List<String> transferableFieldKeysForScope(LibraryEditScope scope) {
    return switch (scope) {
      LibraryEditScope.media => kTransferableMediaFieldKeys,
      LibraryEditScope.release => kTransferableReleaseFieldKeys,
      LibraryEditScope.all => kDefaultTransferableFieldKeys,
    };
  }

  List<TransferableField> transferableFieldsWithCustomFieldsForScope(
    List<CustomFieldDefinition> definitions,
    LibraryEditScope scope,
  ) {
    return TransferableField.withCustomFields(
      definitions,
      fieldKeys: transferableFieldKeysForScope(scope),
    );
  }

  bool get usesTitleAsSeriesFallback =>
      manualAddUsesTitleAsSeries || editUsesTitleAsSeries;

  List<String> get availableGroupModes {
    final module = libraryKindModuleForType(this);
    return [
      for (final definition in module.fields.groups)
        definition.id.value,
    ];
  }

  LibraryWorkspaceDensityPreset get defaultDensityPreset =>
      workspace.defaultDensityPreset;

  List<LibraryWorkspaceDensityPreset> get availableDensityPresets =>
      workspace.availableDensityPresets;

  LibrarySortDefinition<LibraryWorkspaceEntry> sortColumnDefinitionFor(Object column) {
    final module = libraryKindModuleForType(this);
    final id = _definitionIdFor(column);
    final definition = module.fields.sortDefinitionForId(id);
    if (definition != null) {
      return definition;
    }
    return LibrarySortDefinition<LibraryWorkspaceEntry>(
      id: id,
      label: libraryFallbackLabelForId(id),
      compare: (left, right) => left.resolvedTitle.toLowerCase().compareTo(
            right.resolvedTitle.toLowerCase(),
          ),
    );
  }

  bool supportsSortColumn(Object column) {
    final columnId = _definitionIdFor(column);
    final module = libraryKindModuleForType(this);
    return availableSortColumns.any(
          (value) => _definitionIdFor(value) == columnId,
        ) ||
        module.fields.sortDefinitionForId(columnId) != null ||
        module.fields.sortDefinitionForId(columnId.split('.').last) != null;
  }

  bool supportsTableColumn(Object column) {
    final columnId = _definitionIdFor(column);
    final module = libraryKindModuleForType(this);
    return availableTableColumns.any(
          (definition) => _definitionIdFor(definition) == columnId,
        ) ||
        module.fields.columnDefinitionForId(columnId) != null ||
        module.fields.columnDefinitionForId(columnId.split('.').last) != null;
  }

  String sortColumnFieldId(Object column) {
    return sortColumnDefinitionFor(column).id;
  }

  Object? sortColumnFromFieldId(String? fieldId) {
    final normalized = _definitionIdFor(fieldId);
    if (normalized.isEmpty) {
      return null;
    }
    if (supportsSortColumn(normalized)) {
      return normalized;
    }
    final shortId = normalized.split('.').last;
    return supportsSortColumn(shortId) ? shortId : null;
  }

  bool supportsDensityPreset(LibraryWorkspaceDensityPreset preset) {
    return workspace.availableDensityPresets.contains(preset);
  }

  String preferenceKey(String suffix) => workspace.preferenceKey(suffix);

  bool get supportsMediaReleaseSplit => capabilities.supportsMediaReleaseSplit;

  bool get supportsReadingQueue => capabilities.supportsReadingQueue;

  bool get supportsIndexReassignment => capabilities.supportsIndexReassignment;

  bool get supportsMetadataCompareWithServer =>
      capabilities.supportsMetadataCompare;

  bool get supportsSeriesIssueJump =>
      workspaceBehavior.supportsSeriesIssueJump ||
      presentation.supportsSeriesIssueJump;

  bool get hasConditionPickList => conditions.isNotEmpty;

  bool get hasGradePickList => grades.isNotEmpty;

  List<String> availableGroupModesForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    if (!capabilities.scopesOptionsByBrowserMode) {
      return availableGroupModes;
    }
    final scoped = browserMode == LibraryWorkspaceBrowserMode.releases
        ? capabilities.releaseScopeGroupModes
        : capabilities.mediaScopeGroupModes;
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
    if (!capabilities.scopesOptionsByBrowserMode) {
      return availableSortColumns;
    }
    final scoped = browserMode == LibraryWorkspaceBrowserMode.releases
        ? capabilities.releaseScopeSortColumns
        : capabilities.mediaScopeSortColumns;
    if (scoped == null) {
      return availableSortColumns;
    }
    return [
      for (final column in availableSortColumns)
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
    if (workspace.kind == CatalogMediaKind.unknown) {
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

  String _definitionIdFor(Object? value) {
    if (value == null) {
      return '';
    }
    final normalized = value.toString().trim();
    if (normalized.isEmpty) {
      return '';
    }
    if (value is String) {
      return normalized;
    }
    return normalized.contains('.') ? normalized.split('.').last : normalized;
  }
}
