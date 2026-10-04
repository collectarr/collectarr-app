import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';

// Pluggable pane builder typedefs and their request payloads for the
// library add dialog. Extracted from library_add_dialog.dart to keep the
// dialog state file focused on behavior.

typedef LibraryAddPreviewPaneBuilder = Widget Function(
  BuildContext context,
  LibraryAddPreviewPaneRequest request,
);

class LibraryAddManualPaneRequest {
  const LibraryAddManualPaneRequest({
    required this.kind,
    required this.accent,
    required this.type,
    this.commonDraft,
    this.kindDraft,
    this.personalFields = const <PersonalLibraryFieldSpec>[],
    this.onCommonDraftChanged,
    this.onKindDraftChanged,
    required this.tagsController,
    required this.personalNotesController,
    required this.coverPriceController,
    required this.priceController,
    required this.purchaseDateController,
    required this.purchaseStoreController,
    required this.sellPriceController,
    required this.soldDateController,
    required this.ownerLabelController,
    required this.isAdding,
    required this.defaultCondition,
    this.conditions = const [],
    this.tagOptions = const [],
    this.ownerOptions = const [],
    this.purchaseStoreOptions = const [],
    this.locations = const [],
    this.defaultLocationId,
    required this.defaultLocationLabel,
    required this.defaultPurchaseDate,
    required this.defaultTags,
    required this.onAddEntry,
    required this.onAddWishlist,
    required this.onAddTrack,
    required this.onPropose,
    required this.manualDraft,
    this.customFieldDefinitions = const [],
    this.customFieldValues = const {},
    this.onCustomFieldValuesChanged,
    this.itemImages = const [],
    this.onItemImagesChanged,
    this.onVocabularyValueChanged,
    this.onVocabularyValuesChanged,
    this.onManualDraftChanged,
  });

  final CatalogMediaKind kind;
  final Color accent;
  final LibraryKindRegistration type;
  final LibraryAddCommonDraft? commonDraft;
  final LibraryAddKindDraft? kindDraft;
  final List<PersonalLibraryFieldSpec> personalFields;
  final LibraryKindAddDraft manualDraft;
  final ValueChanged<LibraryAddCommonDraft>? onCommonDraftChanged;
  final ValueChanged<LibraryAddKindDraft>? onKindDraftChanged;
  final TextEditingController tagsController;
  final TextEditingController personalNotesController;
  final TextEditingController coverPriceController;
  final TextEditingController priceController;
  final TextEditingController purchaseDateController;
  final TextEditingController purchaseStoreController;
  final TextEditingController sellPriceController;
  final TextEditingController soldDateController;
  final TextEditingController ownerLabelController;
  final bool isAdding;
  final String defaultCondition;
  final List<String> conditions;
  final List<String> tagOptions;
  final List<String> ownerOptions;
  final List<String> purchaseStoreOptions;
  final List<StorageLocation> locations;
  final String? defaultLocationId;
  final String? defaultLocationLabel;
  final DateTime? defaultPurchaseDate;
  final String? defaultTags;
  final VoidCallback onAddEntry;
  final VoidCallback onAddWishlist;
  final VoidCallback onAddTrack;
  final VoidCallback onPropose;

  // Custom fields and images
  final List<CustomFieldDefinition> customFieldDefinitions;
  final Map<String, String?> customFieldValues;
  final ValueChanged<Map<String, String?>>? onCustomFieldValuesChanged;
  final List<ItemImageDraft> itemImages;
  final ValueChanged<List<ItemImageEdit>>? onItemImagesChanged;
  final LibraryVocabularyValueChanged? onVocabularyValueChanged;
  final LibraryVocabularyValuesChanged? onVocabularyValuesChanged;
  final VoidCallback? onManualDraftChanged;

  TDraft manualDraftAs<TDraft extends LibraryKindAddDraft>() =>
      manualDraft as TDraft;
}

class LibraryAddPreviewPaneRequest {
  const LibraryAddPreviewPaneRequest({
    required this.type,
    required this.accent,
    required this.item,
    required this.isFetchingPreview,
    required this.searched,
  });

  final LibraryKindRegistration type;
  final Color accent;
  final CatalogSearchCandidate? item;
  final bool isFetchingPreview;
  final bool searched;
}

class LibraryAddModeBarRequest {
  const LibraryAddModeBarRequest({
    required this.type,
    required this.accent,
    required this.isWideLayout,
    required this.mode,
    required this.queryController,
    required this.identifierController,
    required this.isSearching,
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
    required this.onLookupIdentifier,
    required this.onManual,
    required this.showAdvanced,
    required this.onToggleAdvanced,
    required this.advancedFilterState,
    required this.onAdvancedFilterChanged,
    required this.advancedFilterDescriptors,
    this.kindSpecificPaneBuilder,
  });

  final LibraryKindRegistration type;
  final Color accent;
  final bool isWideLayout;
  final LibraryAddDialogMode mode;
  final TextEditingController queryController;
  final TextEditingController identifierController;
  final bool isSearching;
  final ValueChanged<LibraryAddDialogMode> onModeChanged;
  final VoidCallback onSearch;
  final ValueChanged<String> onQueryChanged;
  final List<CatalogSearchCandidate> suggestions;
  final bool showSuggestions;
  final ValueChanged<CatalogSearchCandidate> onSelectSuggestion;
  final VoidCallback onDismissSuggestions;
  final bool canScanCover;
  final bool isScanningCover;
  final VoidCallback onScanCover;
  final VoidCallback onLookupIdentifier;
  final VoidCallback onManual;
  final bool showAdvanced;
  final VoidCallback onToggleAdvanced;
  final Map<LibraryAddFilterId, LibraryAddFilterValue> advancedFilterState;
  final LibraryAddAdvancedFilterChanged onAdvancedFilterChanged;
  final List<LibraryAddAdvancedFilterField<String>> advancedFilterDescriptors;
  final Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      kindSpecificPaneBuilder;

  String advancedFilterText(LibraryAddFilterId id) {
    return advancedFilterState[id]?.displayValue ?? '';
  }
}

class LibraryAddBottomBarRequest {
  const LibraryAddBottomBarRequest({
    required this.type,
    required this.conditions,
    required this.defaultTags,
    required this.accent,
    required this.selectedItem,
    required this.addTarget,
    required this.addCount,
    this.hasCheckedSelection = false,
    required this.isAdding,
    required this.defaultCondition,
    required this.defaultLocationLabel,
    required this.defaultPurchaseDate,
    required this.onAddTargetChanged,
    required this.onDefaultConditionChanged,
    required this.onEditDefaultTagsPressed,
    required this.onDefaultLocationPressed,
    required this.onDefaultPurchaseDateChanged,
    required this.onAdd,
    required this.isWideLayout,
  });

  final LibraryKindRegistration type;
  final List<String> conditions;
  final String? defaultTags;
  final Color accent;
  final CatalogSearchCandidate? selectedItem;
  final LibraryAddTarget addTarget;
  final int addCount;
  final bool hasCheckedSelection;
  final bool isAdding;
  final String defaultCondition;
  final String? defaultLocationLabel;
  final DateTime? defaultPurchaseDate;
  final ValueChanged<LibraryAddTarget> onAddTargetChanged;
  final ValueChanged<String> onDefaultConditionChanged;
  final VoidCallback onEditDefaultTagsPressed;
  final VoidCallback onDefaultLocationPressed;
  final ValueChanged<DateTime?> onDefaultPurchaseDateChanged;
  final VoidCallback? onAdd;
  final bool isWideLayout;
}
