import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const kDefaultTransferableFieldKeys = [
  'condition',
  'grade',
  'personalNotes',
  'locationId',
  'tags',
  'currency',
  'readStatus',
  'soldTo',
  'features',
  'purchaseStore',
  'boxSetName',
  'pricePaidCents',
  'coverPriceCents',
  'sellPriceCents',
  'quantity',
  'indexNumber',
  'rating',
  'purchaseDate',
  'startedAt',
  'finishedAt',
  'soldAt',
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
    this.wishlistItem,
    this.trackingEntry,
    this.availableBundleReleases = const [],
    this.physicalFormats = const [],
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final OwnedItem? ownedItem;
  final Color accent;
  final WishlistItem? wishlistItem;
  final TrackingEntry? trackingEntry;
  final List<BundleReleaseSummary> availableBundleReleases;
  final List<PhysicalMediaFormat> physicalFormats;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;
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
    this.ownedCopies = const [],
    required this.trackingEntry,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final List<OwnedItem> ownedCopies;
  final TrackingEntry? trackingEntry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;
}

typedef LibraryInspectorSectionsBuilder = List<Widget> Function(
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
}

typedef LibraryInspectorPanelBuilder = Widget Function(
  BuildContext context,
  LibraryInspectorPanelRequest request,
);

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
    this.supportsVideoKindFilters = false,
    this.supportsMediaReleaseSplit = false,
    this.supportsReadingQueue = false,
    this.wideDialog = false,
    this.videoSeriesEntryTypes = const {},
    this.videoShelfDrilldownEntryTypes = const {},
  });

  final bool showsSynopsis;
  final bool showsTrackData;
  final bool showsCreatorSpotlight;
  final LibraryContentHierarchy contentHierarchy;
  final bool canScanCover;
  final bool supportsOwnedItemImages;
  final bool supportsVideoKindFilters;
  final bool supportsMediaReleaseSplit;
  final bool supportsReadingQueue;
  final bool wideDialog;
  final Set<String> videoSeriesEntryTypes;
  final Set<String> videoShelfDrilldownEntryTypes;

  bool get usesSeasonHierarchy =>
      contentHierarchy == LibraryContentHierarchy.seasons;

  bool get usesVolumeHierarchy =>
      contentHierarchy == LibraryContentHierarchy.volumes;

  bool isVideoSeriesEntryType(String mediaType) {
    return videoSeriesEntryTypes.contains(mediaType.trim().toLowerCase());
  }

  bool supportsVideoShelfDrilldown(String mediaType) {
    return videoShelfDrilldownEntryTypes
        .contains(mediaType.trim().toLowerCase());
  }
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
    this.detailPageBuilder,
    this.inspectorPanelBuilder,
    this.inspectorHeroBuilder,
    this.inspectorSectionsBuilder,
    this.showsDefaultInspectorPersonalSection = true,
  });

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
  final LibraryDetailPageBuilder? detailPageBuilder;
  final LibraryInspectorPanelBuilder? inspectorPanelBuilder;
  final LibraryInspectorHeroBuilder? inspectorHeroBuilder;
  final LibraryInspectorSectionsBuilder? inspectorSectionsBuilder;
  final bool showsDefaultInspectorPersonalSection;

  List<TransferableField> transferableFieldsWithCustomFields(
    List<CustomFieldDefinition> definitions,
  ) {
    return TransferableField.withCustomFields(
      definitions,
      fieldKeys: transferableFieldKeys,
    );
  }

  bool get usesTitleAsSeriesFallback =>
      manualAddUsesTitleAsSeries || editUsesTitleAsSeries;

  List<LibraryGroupMode> get availableGroupModes => presentation.groupModes;

  List<LibrarySortColumn> get availableSortColumns =>
      workspace.availableSortColumns;

  List<LibraryTableColumn> get availableTableColumns =>
      workspace.availableTableColumns;

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
}
