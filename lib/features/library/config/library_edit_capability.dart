import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

typedef KindEditDraftFactory = KindEditDraft Function({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
});

/// Encapsulates edit dialogs, edit chrome, field config, condition/grade options,
/// kind-owned draft creation, and update command building.
class LibraryEditCapability {
  const LibraryEditCapability({
    this.editDialogBuilder,
    this.mediaEditDialogBuilder,
    this.releaseEditDialogBuilder,
    this.presentation = const LibraryEditPresentation(
      builder: DefaultLibraryEditPresentationBuilder(),
    ),
    this.editChrome = const LibraryEditChromeConfig(),
    this.mediaFields = const MediaEditFields(),
    this.releaseFields = const ReleaseEditFields(),
    this.conditions = kGeneralConditions,
    this.grades = const [],
    this.defaultCondition,
    this.defaultGrade,
    this.manualAddUsesTitleAsSeries = false,
    this.editUsesTitleAsSeries = false,
    this.createDraft = createGenericEditDraft,
  });

  final LibraryEditDialogBuilder? editDialogBuilder;
  final LibraryEditDialogBuilder? mediaEditDialogBuilder;
  final LibraryEditDialogBuilder? releaseEditDialogBuilder;
  final LibraryEditPresentation presentation;
  final LibraryEditChromeConfig editChrome;
  final MediaEditFields mediaFields;
  final ReleaseEditFields releaseFields;
  final List<String> conditions;
  final List<String> grades;
  final String? defaultCondition;
  final String? defaultGrade;
  final bool manualAddUsesTitleAsSeries;
  final bool editUsesTitleAsSeries;
  final KindEditDraftFactory createDraft;

  bool get hasConditionPickList => conditions.isNotEmpty;
  bool get hasGradePickList => grades.isNotEmpty;
  bool get usesTitleAsSeriesFallback =>
      manualAddUsesTitleAsSeries || editUsesTitleAsSeries;

  OwnedDetailsDraft buildDetailsDraft(KindEditDraft kindDraft) =>
      kindDraft.toDetailsDraft();

  UpdateOwnedItemCommand buildUpdateCommand({
    required LibraryEditDraft session,
    required String ownedItemId,
    required KindEditDraft kindDraft,
  }) {
    return UpdateOwnedItemCommand(
      ownedItemId: ownedItemId,
      quantity: Patch.set(parseInt(session.quantityController.text) ?? 1),
      condition: session.conditionController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(session.conditionController.text.trim()),
      grade: session.gradeController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(session.gradeController.text.trim()),
      purchaseDate: session.purchaseDateController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseDate(session.purchaseDateController.text)),
      pricePaidCents: session.priceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(session.priceController.text)),
      currency: session.currencyController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(session.currencyController.text.trim()),
      personalNotes: session.notesController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(session.notesController.text.trim()),
      locationId: session.selectedLocationId != null
          ? Patch.set(session.selectedLocationId)
          : const Patch.clear(),
      purchaseStore: session.purchaseStoreController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(session.purchaseStoreController.text.trim()),
      collectionStatus: session.collectionStatus != null
          ? Patch.set(session.collectionStatus)
          : const Patch.clear(),
      tags: session.tagsController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(session.tagsController.text.trim()),
      rating: session.ratingController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseInt(session.ratingController.text)),
      readStatus: session.trackingController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(session.trackingController.text.trim()),
      startedAt: session.startedAt != null
          ? Patch.set(session.startedAt)
          : const Patch.clear(),
      finishedAt: session.finishedAt != null
          ? Patch.set(session.finishedAt)
          : const Patch.clear(),
      soldAt: session.soldAt != null
          ? Patch.set(session.soldAt)
          : const Patch.clear(),
      sellPriceCents: session.sellPriceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(session.sellPriceController.text)),
      soldTo: session.soldToController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(session.soldToController.text.trim()),
      details: Patch.set(buildDetailsDraft(kindDraft)),
    );
  }
}
