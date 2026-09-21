import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_edit_metadata.dart';
import 'package:collectarr_app/core/models/catalog_target_option.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/common_metadata_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/draft/tracking_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart'
    hide formatDate;
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state_factory.dart';

export 'package:collectarr_app/features/library/edit/draft/common_metadata_draft.dart';
export 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
export 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
export 'package:collectarr_app/features/library/edit/draft/tracking_draft.dart';

class LibraryEditShellState {
  /// Low-level state constructor used by [createLibraryEditShellState].
  ///
  /// Callers should normally use [fromRequest], [fromItem], or [fromFields].
  LibraryEditShellState.create({
    required TextControllerGroup textControllers,
    required this.type,
    required this.item,
    required this.kindItem,
    required this.ownedItem,
    required this.ownedItemDispatch,
    required this.wishlistItem,
    required this.trackingSummary,
    required this.accent,
    required this.wishlistTargetOptions,
    required this.physicalFormats,
    required this.customFieldDefinitions,
    required this.customFieldValues,
    required this.itemImages,
    required this.metadata,
    required this.personal,
    required this.tracking,
    required this.kindDetails,
    required this.customFieldEdits,
    required this.itemImageEdits,
  }) : _textControllers = textControllers;

  final TextControllerGroup _textControllers;

  final LibraryKindRegistration type;
  final CatalogEditMetadata item;

  /// The selected transport candidate is retained only for the kind-owned
  /// draft and final catalog mutation boundary. The shared shell reads
  /// [item], never the transport candidate's rich payload.
  final CatalogSearchCandidate kindItem;
  final OwnedItemSummary? ownedItem;
  final LibraryOwnedItemDispatch? ownedItemDispatch;
  final WishlistItem? wishlistItem;
  final TrackingSummary? trackingSummary;
  final Color accent;
  final List<CatalogTargetOption> wishlistTargetOptions;
  final List<PhysicalMediaFormat> physicalFormats;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;

  /// Modular Sub-Drafts
  final CommonMetadataDraft metadata;
  final PersonalStateDraft personal;
  final TrackingDraft tracking;
  final LibraryKindEditSession kindDetails;

  Map<String, String?> customFieldEdits;
  List<ItemImageEdit> itemImageEdits;
  List<String> locationOptions = const [];
  List<String> ownerOptions = const [];
  List<String> tagOptions = const [];
  Map<String, List<String>> kindVocabularies = const {};

  // ---------------------------------------------------------------------------
  // Factory Constructors
  // ---------------------------------------------------------------------------

  factory LibraryEditShellState.fromRequest(LibraryEditDialogRequest request) {
    return LibraryEditShellState.fromFields(
      type: request.type,
      item: request.kindItem,
      ownedItem: request.ownedItem,
      ownedItemDispatch: request.ownedItemDispatch,
      wishlistItem: request.wishlistItem,
      trackingSummary: request.trackingSummary,
      accent: request.accent,
      wishlistTargetOptions: request.wishlistTargetOptions,
      physicalFormats: request.physicalFormats,
      customFieldDefinitions: request.customFieldDefinitions,
      customFieldValues: request.customFieldValues,
      itemImages: request.itemImages,
    );
  }

  factory LibraryEditShellState.fromItem({
    required LibraryKindRegistration type,
    required CatalogSearchCandidate item,
    OwnedItemSummary? ownedItem,
    LibraryOwnedItemDispatch? ownedItemDispatch,
    WishlistItem? wishlistItem,
    TrackingSummary? trackingSummary,
    required Color accent,
    List<CatalogTargetOption> wishlistTargetOptions = const [],
    List<PhysicalMediaFormat> physicalFormats = const [],
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    List<CustomFieldValue> customFieldValues = const [],
    List<ItemImage> itemImages = const [],
  }) {
    return LibraryEditShellState.fromFields(
      type: type,
      item: item,
      ownedItem: ownedItem,
      ownedItemDispatch: ownedItemDispatch,
      wishlistItem: wishlistItem,
      trackingSummary: trackingSummary,
      accent: accent,
      wishlistTargetOptions: wishlistTargetOptions,
      physicalFormats: physicalFormats,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValues: customFieldValues,
      itemImages: itemImages,
    );
  }

  factory LibraryEditShellState.fromFields({
    required LibraryKindRegistration type,
    required CatalogSearchCandidate item,
    required OwnedItemSummary? ownedItem,
    LibraryOwnedItemDispatch? ownedItemDispatch,
    required WishlistItem? wishlistItem,
    required TrackingSummary? trackingSummary,
    required Color accent,
    List<CatalogTargetOption> wishlistTargetOptions = const [],
    List<PhysicalMediaFormat> physicalFormats = const [],
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    List<CustomFieldValue> customFieldValues = const [],
    List<ItemImage> itemImages = const [],
  }) =>
      createLibraryEditShellState(
        type: type,
        item: item,
        ownedItem: ownedItem,
        ownedItemDispatch: ownedItemDispatch,
        wishlistItem: wishlistItem,
        trackingSummary: trackingSummary,
        accent: accent,
        wishlistTargetOptions: wishlistTargetOptions,
        physicalFormats: physicalFormats,
        customFieldDefinitions: customFieldDefinitions,
        customFieldValues: customFieldValues,
        itemImages: itemImages,
      );

  // ---------------------------------------------------------------------------
  // Domain Helpers & Actions
  // ---------------------------------------------------------------------------

  bool get isOwned => ownedItem != null;
  bool get hasTrackingContext => isOwned || trackingSummary != null;
  bool get isTrackingOnly => !isOwned && trackingSummary != null;
  bool get hasWishlistContext => wishlistItem != null;
  PhysicalMediaFormat? physicalFormatForId(String? id) {
    final normalized = emptyToNull(id ?? '');
    return normalized == null
        ? null
        : physicalMediaFormatById(normalized, formats: physicalFormats);
  }

  bool get isDigitalFormat {
    final existingOwnedItem = ownedItem;
    final formatHint =
        libraryOwnedEditForKind(type.kind).resolveOwnedFormatHint(kindItem);
    final format = formatHint.label ?? '';
    return libraryOwnedEditForKind(type.kind).resolveOwnedDigitalFlag(
          existingOwnedItem,
          libraryPresentationForKind(type.kind)
              .builder
              .buildReleaseOptions(item: kindItem),
          fallbackFormat: formatHint.format,
          fallbackLabel: format,
          formats: physicalFormats,
        ) ??
        false;
  }

  bool get showPhysicalOwnedFields => isOwned && !isDigitalFormat;

  ({
    String? selectedLocationId,
    DateTime? startedAt,
    DateTime? finishedAt,
    DateTime? soldAt,
    CatalogEntityRef? selectedTargetRef,
    Map<String, String?> customFieldEdits,
    List<ItemImageEdit> itemImageEdits,
  }) cloneDialogState() {
    return (
      selectedLocationId: personal.selectedLocationId,
      startedAt: tracking.startedAt,
      finishedAt: tracking.finishedAt,
      soldAt: personal.soldAt,
      selectedTargetRef: personal.selectedOwnedTargetRef ??
          trackingSummary?.catalogRef ??
          wishlistItem?.catalogRef ??
          item.ref,
      customFieldEdits: Map<String, String?>.from(customFieldEdits),
      itemImageEdits: List<ItemImageEdit>.from(itemImageEdits),
    );
  }

  void updateCustomFieldsAndImages({
    required Map<String, String?> customFieldEdits,
    required List<ItemImageEdit> itemImageEdits,
  }) {
    this.customFieldEdits = Map<String, String?>.from(customFieldEdits);
    this.itemImageEdits = List<ItemImageEdit>.from(itemImageEdits);
  }

  void replaceMediaEdits({
    required Map<String, String?> customFieldEdits,
    required List<ItemImageEdit> itemImageEdits,
  }) =>
      updateCustomFieldsAndImages(
        customFieldEdits: customFieldEdits,
        itemImageEdits: itemImageEdits,
      );

  void dispose() {
    kindDetails.dispose();
    _textControllers.dispose();
  }
}
