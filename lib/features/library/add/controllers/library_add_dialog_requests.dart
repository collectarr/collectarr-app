import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';

// Pluggable pane builder typedefs and their request payloads for the
// library add dialog. Extracted from library_add_dialog.dart to keep the
// dialog state file focused on behavior.

typedef LibraryAddManualPaneBuilder = Widget Function(
  BuildContext context,
  LibraryAddManualPaneRequest request,
);

typedef LibraryAddPreviewPaneBuilder = Widget Function(
  BuildContext context,
  LibraryAddPreviewPaneRequest request,
);

typedef LibraryAddHeaderBuilder = Widget Function(
  BuildContext context,
  LibraryAddHeaderRequest request,
);

typedef LibraryAddModeBarBuilder = Widget Function(
  BuildContext context,
  LibraryAddModeBarRequest request,
);

typedef LibraryAddSearchPaneBuilder = Widget Function(
  BuildContext context,
  LibraryAddSearchPaneRequest request,
);

typedef LibraryAddBottomBarBuilder = Widget Function(
  BuildContext context,
  LibraryAddBottomBarRequest request,
);

class LibraryAddManualPaneRequest {
  const LibraryAddManualPaneRequest({
    required this.kind,
    required this.accent,
    required this.type,
    this.commonDraft,
    this.kindDraft,
    this.onCommonDraftChanged,
    this.onKindDraftChanged,
    required this.titleController,
    required this.tagsController,
    required this.personalNotesController,
    required this.coverPriceController,
    required this.priceController,
    required this.purchaseDateController,
    required this.purchaseStoreController,
    required this.sellPriceController,
    required this.soldDateController,
    required this.ownerLabelController,
    required this.linksController,
    required this.isAdding,
    required this.defaultCondition,
    required this.defaultGrade,
    required this.defaultLocationLabel,
    required this.defaultPurchaseDate,
    required this.defaultTags,
    required this.onAddOwned,
    required this.onAddWishlist,
    required this.onAddTrack,
    required this.manualDraft,
    this.customFieldDefinitions = const [],
    this.customFieldValues = const {},
    this.onCustomFieldValuesChanged,
    this.itemImages = const [],
    this.onItemImagesChanged,
  });

  final CatalogMediaKind kind;
  final Color accent;
  final LibraryKindModule type;
  final LibraryAddCommonDraft? commonDraft;
  final LibraryAddKindDraft? kindDraft;
  final LibraryKindAddDraft manualDraft;
  final ValueChanged<LibraryAddCommonDraft>? onCommonDraftChanged;
  final ValueChanged<LibraryAddKindDraft>? onKindDraftChanged;
  final TextEditingController titleController;
  final TextEditingController tagsController;
  final TextEditingController personalNotesController;
  final TextEditingController coverPriceController;
  final TextEditingController priceController;
  final TextEditingController purchaseDateController;
  final TextEditingController purchaseStoreController;
  final TextEditingController sellPriceController;
  final TextEditingController soldDateController;
  final TextEditingController ownerLabelController;
  final TextEditingController linksController;
  final bool isAdding;
  final String defaultCondition;
  final String defaultGrade;
  final String? defaultLocationLabel;
  final DateTime? defaultPurchaseDate;
  final String? defaultTags;
  final VoidCallback onAddOwned;
  final VoidCallback onAddWishlist;
  final VoidCallback onAddTrack;

  // Custom fields and images
  final List<CustomFieldDefinition> customFieldDefinitions;
  final Map<String, String?> customFieldValues;
  final ValueChanged<Map<String, String?>>? onCustomFieldValuesChanged;
  final List<ItemImage> itemImages;
  final ValueChanged<List<ItemImageEdit>>? onItemImagesChanged;

  TDraft manualDraftAs<TDraft extends LibraryKindAddDraft>() =>
      manualDraft as TDraft;
}

class LibraryAddPreviewPaneRequest {
  const LibraryAddPreviewPaneRequest({
    required this.type,
    required this.accent,
    required this.item,
    required this.candidate,
    required this.candidatePreview,
    required this.isFetchingPreview,
    required this.providerLabel,
    required this.searched,
    required this.addTarget,
    required this.referenceType,
    required this.availableBundleReleases,
    required this.selectedBundleReleaseId,
    required this.selectedBundleReleaseDetail,
    required this.selectedEditionId,
    required this.selectedVariantId,
    required this.isLoadingBundleReleases,
    required this.isLoadingBundleReleaseDetail,
    required this.onReferenceTypeChanged,
    required this.onEditionSelected,
    required this.onVariantSelected,
    required this.onBundleReleaseSelected,
  });

  final LibraryKindModule type;
  final Color accent;
  final CatalogItem? item;
  final ProviderCandidate? candidate;
  final AdminProviderPreview? candidatePreview;
  final bool isFetchingPreview;
  final String providerLabel;
  final bool searched;
  final LibraryAddTarget addTarget;
  final LibraryAddReferenceType referenceType;
  final List<BundleReleaseSummary> availableBundleReleases;
  final String? selectedBundleReleaseId;
  final BundleReleaseDetail? selectedBundleReleaseDetail;
  final String? selectedEditionId;
  final String? selectedVariantId;
  final bool isLoadingBundleReleases;
  final bool isLoadingBundleReleaseDetail;
  final ValueChanged<LibraryAddReferenceType> onReferenceTypeChanged;
  final ValueChanged<String> onEditionSelected;
  final ValueChanged<String> onVariantSelected;
  final ValueChanged<String> onBundleReleaseSelected;
}

class LibraryAddHeaderRequest {
  const LibraryAddHeaderRequest({
    required this.type,
    required this.accent,
    required this.onClose,
  });

  final LibraryKindModule type;
  final Color accent;
  final VoidCallback onClose;
}

class LibraryAddModeBarRequest {
  const LibraryAddModeBarRequest({
    required this.type,
    required this.accent,
    required this.isWideLayout,
    required this.mode,
    required this.queryController,
    required this.barcodeController,
    required this.isSearching,
    required this.isSearchingProvider,
    required this.onModeChanged,
    required this.onSearch,
    required this.onQueryChanged,
    required this.suggestions,
    required this.showSuggestions,
    required this.onSelectSuggestion,
    required this.onDismissSuggestions,
    required this.canScanCover,
    required this.isScanningCover,
    required this.onScanCover,
    required this.onLookupBarcode,
    required this.onManual,
    required this.showAdvanced,
    required this.onToggleAdvanced,
    required this.advancedFilterState,
    required this.onAdvancedFilterChanged,
    required this.advancedFilterDescriptors,
    this.kindSpecificPaneBuilder,
  });

  final LibraryKindModule type;
  final Color accent;
  final bool isWideLayout;
  final LibraryAddDialogMode mode;
  final TextEditingController queryController;
  final TextEditingController barcodeController;
  final bool isSearching;
  final bool isSearchingProvider;
  final ValueChanged<LibraryAddDialogMode> onModeChanged;
  final VoidCallback onSearch;
  final ValueChanged<String> onQueryChanged;
  final List<CatalogItem> suggestions;
  final bool showSuggestions;
  final ValueChanged<CatalogItem> onSelectSuggestion;
  final VoidCallback onDismissSuggestions;
  final bool canScanCover;
  final bool isScanningCover;
  final VoidCallback onScanCover;
  final VoidCallback onLookupBarcode;
  final VoidCallback onManual;
  final bool showAdvanced;
  final VoidCallback onToggleAdvanced;
  final Map<LibraryAddFilterId, Object?> advancedFilterState;
  final LibraryAddAdvancedFilterChanged onAdvancedFilterChanged;
  final List<LibraryAddAdvancedFilterField<String>> advancedFilterDescriptors;
  final Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      kindSpecificPaneBuilder;

  String advancedFilterText(LibraryAddFilterId id) {
    return advancedFilterState[id]?.toString() ?? '';
  }
}

class LibraryAddSearchPaneRequest {
  const LibraryAddSearchPaneRequest({
    required this.type,
    required this.isBusy,
    required this.error,
    required this.accent,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.selectedProvider,
    required this.searchedProvider,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.checkedResultIds,
    required this.checkedProviderIds,
    required this.ownedCatalogItemIds,
    this.coreMatchSummary,
    this.providerMatchSummary,
    required this.resultPolicy,
    required this.resultPolicyState,
    required this.onResultPolicyOptionChanged,
    required this.isWideLayout,
    required this.showCoreResults,
    required this.showProviderResults,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onToggleResultCheck,
    required this.onToggleProviderCheck,
    required this.onShowCoreResultsChanged,
    required this.onShowProviderResultsChanged,
    required this.onSearchCore,
  });

  final LibraryKindModule type;
  final bool isBusy;
  final String? error;
  final Color accent;
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final String selectedProvider;
  final bool searchedProvider;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> checkedProviderIds;
  final Set<String> ownedCatalogItemIds;
  final String? Function(CatalogItem item)? coreMatchSummary;
  final String? Function(ProviderCandidate candidate)? providerMatchSummary;
  final LibraryAddResultPolicy resultPolicy;
  final LibraryAddResultPolicyState resultPolicyState;
  final void Function(String id, bool value) onResultPolicyOptionChanged;
  final bool isWideLayout;
  final bool showCoreResults;
  final bool showProviderResults;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;
  final ValueChanged<String> onToggleProviderCheck;
  final ValueChanged<bool> onShowCoreResultsChanged;
  final ValueChanged<bool> onShowProviderResultsChanged;
  final VoidCallback onSearchCore;
}

class LibraryAddBottomBarRequest {
  const LibraryAddBottomBarRequest({
    required this.type,
    required this.conditions,
    required this.grades,
    required this.defaultTags,
    required this.accent,
    required this.selectedItem,
    required this.selectedCandidate,
    required this.selectedQueuedIngest,
    required this.providerLabel,
    required this.addTarget,
    required this.addCount,
    required this.isAdding,
    required this.isQueueingIngest,
    required this.isAdmin,
    required this.defaultCondition,
    required this.defaultGrade,
    required this.defaultLocationLabel,
    required this.defaultPurchaseDate,
    required this.onAddTargetChanged,
    required this.onDefaultConditionChanged,
    required this.onDefaultGradeChanged,
    required this.onEditDefaultTagsPressed,
    required this.onDefaultLocationPressed,
    required this.onDefaultPurchaseDateChanged,
    required this.onAdd,
    required this.onQueueIngest,
    required this.onPropose,
  });

  final LibraryKindModule type;
  final List<String> conditions;
  final List<String> grades;
  final String? defaultTags;
  final Color accent;
  final CatalogItem? selectedItem;
  final ProviderCandidate? selectedCandidate;
  final LibraryQueuedProviderIngest? selectedQueuedIngest;
  final String providerLabel;
  final LibraryAddTarget addTarget;
  final int addCount;
  final bool isAdding;
  final bool isQueueingIngest;
  final bool isAdmin;
  final String defaultCondition;
  final String defaultGrade;
  final String? defaultLocationLabel;
  final DateTime? defaultPurchaseDate;
  final ValueChanged<LibraryAddTarget> onAddTargetChanged;
  final ValueChanged<String> onDefaultConditionChanged;
  final ValueChanged<String> onDefaultGradeChanged;
  final VoidCallback onEditDefaultTagsPressed;
  final VoidCallback onDefaultLocationPressed;
  final ValueChanged<DateTime?> onDefaultPurchaseDateChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onQueueIngest;
  final VoidCallback? onPropose;
}
