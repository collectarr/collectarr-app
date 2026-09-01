import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

import 'package:collectarr_app/features/library/config/library_type_config.dart';

export 'package:collectarr_app/features/library/config/edit_field_config.dart';
export 'package:collectarr_app/features/library/config/library_chrome_config.dart';
export 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
export 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';

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
    this.vocabularies,
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
  final LibraryKindVocabularyCapability? vocabularies;
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
    final personal = session.personal;
    final tracking = session.tracking;
    return UpdateOwnedItemCommand(
      ownedItemId: ownedItemId,
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
      rating: tracking.ratingController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseInt(tracking.ratingController.text)),
      readStatus: tracking.trackingController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(tracking.trackingController.text.trim()),
      startedAt: tracking.startedAt != null
          ? Patch.set(tracking.startedAt)
          : const Patch.clear(),
      finishedAt: tracking.finishedAt != null
          ? Patch.set(tracking.finishedAt)
          : const Patch.clear(),
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
  }
}
