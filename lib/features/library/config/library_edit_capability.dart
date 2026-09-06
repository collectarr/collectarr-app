import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

export 'package:collectarr_app/features/library/config/library_chrome_config.dart';
export 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
export 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
export 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
export 'package:collectarr_app/features/library/config/library_owned_copy_semantics.dart';

typedef LibraryEditKindDraftFactory = LibraryEditKindDraft Function({
  required CatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
});

typedef LibraryOwnedUpdatePayloadBuilder = OwnedItemUpdatePayload Function(
  LegacyUpdateOwnedItemCommand<OwnedDetailsDraft> command,
);

/// Encapsulates edit dialogs, edit chrome, field config, condition/grade options,
/// kind-owned draft creation, and update command building.
class LibraryEditCapability {
  const LibraryEditCapability({
    this.editDialogBuilder,
    this.mediaEditDialogBuilder,
    this.releaseEditDialogBuilder,
    required this.presentation,
    this.editChrome = const LibraryEditChromeConfig(),
    this.vocabularies,
    required this.conditions,
    this.grades = const [],
    required this.defaultCondition,
    required this.defaultGrade,
    required this.createDraft,
    required this.ownedDigitalFlagResolver,
    this.ownedUpdatePayloadBuilder,
  });

  final LibraryEditDialogBuilder? editDialogBuilder;
  final LibraryEditDialogBuilder? mediaEditDialogBuilder;
  final LibraryEditDialogBuilder? releaseEditDialogBuilder;
  final LibraryEditPresentation presentation;
  final LibraryEditChromeConfig editChrome;
  final LibraryKindVocabularyCapability? vocabularies;
  final List<String> conditions;
  final List<String> grades;
  final String defaultCondition;
  final String defaultGrade;
  final LibraryEditKindDraftFactory createDraft;
  final LibraryOwnedDigitalFlagResolver ownedDigitalFlagResolver;
  final LibraryOwnedUpdatePayloadBuilder? ownedUpdatePayloadBuilder;

  bool get hasConditionPickList => conditions.isNotEmpty;
  bool get hasGradePickList => grades.isNotEmpty;

  bool? resolveOwnedDigitalFlag(
    OwnedItem? ownedItem,
    List<CatalogEdition> editions, {
    String? fallbackFormat,
    String? fallbackLabel,
    Iterable<PhysicalMediaFormat> formats = const [],
  }) {
    return ownedDigitalFlagResolver(
      ownedItem,
      editions,
      fallbackFormat: fallbackFormat,
      fallbackLabel: fallbackLabel,
      formats: formats,
    );
  }

  OwnedDetailsDraft buildDetailsDraft(LibraryEditKindDraft kindDraft) =>
      kindDraft.toDetailsDraft();

  UpdateOwnedItemCommand withTypedUpdatePayload(
    LegacyUpdateOwnedItemCommand<OwnedDetailsDraft> command,
  ) {
    final builder = ownedUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned update payload builder is registered.');
    }
    return UpdateOwnedItemCommand(
      ownedItemId: command.ownedItemId,
      payload: builder(command),
    );
  }

  OwnedItemUpdateRequest buildUpdateCommand({
    required LibraryEditDraft session,
    required String ownedItemId,
    required LibraryEditKindDraft kindDraft,
  }) {
    final personal = session.personal;
    final command = LegacyUpdateOwnedItemCommand<OwnedDetailsDraft>(
      ownedItemId: ownedItemId,
      anchor: Patch.set(
        PersonalItemAnchor.fromRaw(
          anchorType: personal.selectedOwnedAnchorType.apiValue,
          editionId: personal.selectedEditionId,
          variantId: personal.selectedVariantId,
          bundleReleaseId: personal.selectedBundleReleaseId,
        ),
      ),
      quantity: Patch.set(parseInt(personal.quantityController.text) ?? 1),
      condition: personal.conditionController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.conditionController.text.trim()),
      grade: personal.gradeController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.gradeController.text.trim()),
      purchaseDate: personal.purchaseDateController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseDate(personal.purchaseDateController.text)),
      pricePaidCents: personal.priceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(personal.priceController.text)),
      currency: personal.currencyController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.currencyController.text.trim()),
      personalNotes: personal.notesController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.notesController.text.trim()),
      locationId: personal.selectedLocationId != null
          ? Patch.set(personal.selectedLocationId)
          : const Patch.clear(),
      purchaseStore: personal.purchaseStoreController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.purchaseStoreController.text.trim()),
      collectionStatus: personal.collectionStatus != null
          ? Patch.set(personal.collectionStatus)
          : const Patch.clear(),
      tags: personal.tagsController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.tagsController.text.trim()),
      soldAt: personal.soldAt != null
          ? Patch.set(personal.soldAt)
          : const Patch.clear(),
      sellPriceCents: personal.sellPriceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(personal.sellPriceController.text)),
      soldTo: personal.soldToController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.soldToController.text.trim()),
      details: Patch.set(buildDetailsDraft(kindDraft)),
    );
    final builder = ownedUpdatePayloadBuilder;
    return builder == null
        ? command
        : UpdateOwnedItemCommand(
            ownedItemId: command.ownedItemId,
            payload: builder(command),
          );
  }
}
