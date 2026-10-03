import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/catalog_target_option.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/session/library_edit_session_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

/// Builds common edit state from the typed Library boundary and asks the
/// selected kind session to create its canonical form fields and schema.
LibraryEditShellState createLibraryEditShellState({
  required LibraryKindRegistration type,
  LibraryEntityScope scope = LibraryEntityScope.catalogItem,
  LibraryEntityRef? node,
  required CatalogSearchCandidate item,
  required LibraryEntrySummary? libraryEntry,
  LibraryEntryDispatch? libraryEntryDispatch,
  required WishlistItem? wishlistItem,
  required TrackingSummary? trackingSummary,
  required Color accent,
  List<CatalogTargetOption> wishlistTargetOptions = const [],
  List<PhysicalMediaFormat> physicalFormats = const [],
  List<CustomFieldDefinition> customFieldDefinitions = const [],
  List<CustomFieldValue> customFieldValues = const [],
  List<ItemImage> itemImages = const [],
}) {
  final textControllers = TextControllerGroup();
  TextEditingController create([String text = '']) =>
      textControllers.create(text: text);

  final formFields = LibraryEditFormFields(textControllers);
  final ownerLabelController = create(libraryEntry?.ownerLabel ?? '');
  final conditionController = create();
  final gradeController = create(
    libraryEntryEditForKind(type.kind)
            .readEntryCollectionValue(libraryEntryDispatch) ??
        '',
  );
  final purchaseDateController = create(
    libraryEntry?.purchaseDate == null
        ? ''
        : formatDate(libraryEntry!.purchaseDate!),
  );
  final priceController = create(
    libraryEntry?.pricePaidCents == null
        ? ''
        : (libraryEntry!.pricePaidCents! / 100).toStringAsFixed(2),
  );
  final currencyController = create(libraryEntry?.currency ?? '');
  final indexNumberController = create();
  final notesController = create(libraryEntry?.notes ?? '');
  final wishlistPriceController = create(
    wishlistItem?.targetPriceCents == null
        ? ''
        : (wishlistItem!.targetPriceCents! / 100).toStringAsFixed(2),
  );
  final wishlistCurrencyController = create(wishlistItem?.currency ?? '');
  final wishlistNotesController = create(wishlistItem?.notes ?? '');
  final trackingRating = trackingSummary?.rating;
  final trackingStatus = trackingSummary?.statusStorageValue;
  final ratingController = create(trackingRating?.toString() ?? '');
  final trackingController = create(trackingStatus ?? '');
  final trackingProgress = trackingSummary?.progress;
  final progressCurrentController = create(
    trackingProgress?.current?.toString() ?? '',
  );
  final progressTotalController = create(
    trackingProgress?.total?.toString() ?? '',
  );
  final timesCompletedController = create(
    trackingProgress?.timesCompleted?.toString() ?? '',
  );
  final trackingNotesController = create(trackingSummary?.notes ?? '');
  final tagsController = create();
  final sellPriceController = create(
    libraryEntry?.sellPriceCents == null
        ? ''
        : (libraryEntry!.sellPriceCents! / 100).toStringAsFixed(2),
  );
  final soldToController = create(libraryEntry?.soldTo ?? '');
  final purchaseStoreController = create(libraryEntry?.purchaseStore ?? '');
  final marketValueController = create(
    libraryEntry?.marketValueCents == null
        ? ''
        : (libraryEntry!.marketValueCents! / 100).toStringAsFixed(2),
  );

  final personal = PersonalStateDraft(
    ownerLabelController: ownerLabelController,
    conditionController: conditionController,
    gradeController: gradeController,
    purchaseDateController: purchaseDateController,
    priceController: priceController,
    currencyController: currencyController,
    indexNumberController: indexNumberController,
    notesController: notesController,
    purchaseStoreController: purchaseStoreController,
    marketValueController: marketValueController,
    wishlistPriceController: wishlistPriceController,
    wishlistCurrencyController: wishlistCurrencyController,
    wishlistNotesController: wishlistNotesController,
    tagsController: tagsController,
    sellPriceController: sellPriceController,
    soldToController: soldToController,
    tagOptions: const [],
    availableLocations: const [],
    selectedLocationId: libraryEntry?.locationId,
    selectedWishlistCatalogRef: wishlistItem?.catalogRef,
    locationChanged: false,
    soldAt: libraryEntry?.soldAt,
    collectionStatus: null,
  );

  final tracking = TrackingDraft(
    ratingController: ratingController,
    trackingController: trackingController,
    progressCurrentController: progressCurrentController,
    progressTotalController: progressTotalController,
    timesCompletedController: timesCompletedController,
    trackingNotesController: trackingNotesController,
    startedAt: trackingSummary?.startedAt,
    finishedAt: trackingSummary?.completedAt,
  );

  final kindSessionFactory = libraryEditSessionForKind(type.kind).createSession;
  if (kindSessionFactory == null) {
    throw StateError(
      'The ${type.kind.apiValue} kind uses a dedicated typed edit dialog.',
    );
  }
  final kindSessions = kindSessionFactory(
    item: item,
    // Kind edit schemas consume only the concrete aggregate supplied by the
    // typed Library boundary. The generic request value is never decoded by
    // a kind schema.
    libraryEntryDispatch: libraryEntryDispatch,
    trackingSummary: trackingSummary,
    textControllers: textControllers,
  );
  final canonicalSession = kindSessions.catalogItemSession;
  final builtCanonicalFormSchema = canonicalSession.buildCanonicalFormSchema(
    formFields,
    item,
  );
  final canonicalFormSchema = builtCanonicalFormSchema;
  kindSessions.entrySession.initializePersonalState(personal);

  final formatHint =
      libraryEntryEditForKind(type.kind).resolveEntryFormatHint(item);
  final isDigitalFormat =
      libraryEntryEditForKind(type.kind).resolveEntryDigitalFlag(
            libraryEntry,
            fallbackFormat: formatHint.format,
            fallbackLabel: formatHint.label,
            formats: physicalFormats,
          ) ??
          false;

  return LibraryEditShellState.create(
    textControllers: textControllers,
    type: type,
    scope: scope,
    node: node,
    kindItem: item,
    libraryEntry: libraryEntry,
    libraryEntryDispatch: libraryEntryDispatch,
    wishlistItem: wishlistItem,
    trackingSummary: trackingSummary,
    accent: accent,
    wishlistTargetOptions:
        List<CatalogTargetOption>.unmodifiable(wishlistTargetOptions),
    physicalFormats: List<PhysicalMediaFormat>.unmodifiable(physicalFormats),
    customFieldDefinitions:
        List<CustomFieldDefinition>.unmodifiable(customFieldDefinitions),
    customFieldValues: List<CustomFieldValue>.unmodifiable(customFieldValues),
    itemImages: List<ItemImage>.unmodifiable(itemImages),
    isDigitalFormat: isDigitalFormat,
    formFields: formFields,
    canonicalFormSchema: canonicalFormSchema,
    personal: personal,
    tracking: tracking,
    session: LibraryEditSessionController(
      catalogItemSession: kindSessions.catalogItemSession,
      entrySession: kindSessions.entrySession,
      disposeSession: kindSessions.disposeSession,
    ),
    customFieldEdits: {
      for (final definition in customFieldDefinitions)
        definition.id: _initialCustomFieldValue(
          definition.id,
          customFieldValues,
        ),
    },
    itemImageEdits: const [],
  );
}

String? _initialCustomFieldValue(
  String definitionId,
  List<CustomFieldValue> values,
) {
  for (final value in values) {
    if (value.fieldDefinitionId == definitionId) {
      return value.value;
    }
  }
  return null;
}
