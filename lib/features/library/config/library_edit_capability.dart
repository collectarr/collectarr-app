import 'package:collectarr_app/core/models/owned_item.dart';
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

typedef LibraryOwnedIndexUpdatePayloadBuilder = OwnedItemUpdatePayload Function(
    String ownedItemId, int indexNumber);

typedef LibraryOwnedConditionGradeUpdatePayloadBuilder = OwnedItemUpdatePayload
    Function(String ownedItemId, String? condition, String? grade);

typedef LibraryOwnedBulkUpdatePayloadBuilder = OwnedItemUpdatePayload Function(
  String ownedItemId,
  String? condition,
  String? grade,
  String? locationId,
  String? tags,
);

typedef LibraryOwnedPersonalDetailsUpdatePayloadBuilder = OwnedItemUpdatePayload
    Function(
  String ownedItemId,
  DateTime? purchaseDate,
  int? pricePaidCents,
  String? currency,
  String? personalNotes,
  String? purchaseStore,
  bool locationChanged,
  String? locationId,
);

typedef LibraryOwnedTransferUpdatePayloadBuilder = OwnedItemUpdatePayload
    Function(
  String ownedItemId,
  OwnedItem updated,
  OwnedDetailsDraft details,
);

typedef LibraryOwnedDetailsResetPayloadBuilder = OwnedItemUpdatePayload
    Function();

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
    this.ownedIndexUpdatePayloadBuilder,
    this.ownedConditionGradeUpdatePayloadBuilder,
    this.ownedBulkUpdatePayloadBuilder,
    this.ownedPersonalDetailsUpdatePayloadBuilder,
    this.ownedTransferUpdatePayloadBuilder,
    this.ownedDetailsResetPayloadBuilder,
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
  final LibraryOwnedIndexUpdatePayloadBuilder? ownedIndexUpdatePayloadBuilder;
  final LibraryOwnedConditionGradeUpdatePayloadBuilder?
      ownedConditionGradeUpdatePayloadBuilder;
  final LibraryOwnedBulkUpdatePayloadBuilder? ownedBulkUpdatePayloadBuilder;
  final LibraryOwnedPersonalDetailsUpdatePayloadBuilder?
      ownedPersonalDetailsUpdatePayloadBuilder;
  final LibraryOwnedTransferUpdatePayloadBuilder?
      ownedTransferUpdatePayloadBuilder;
  final LibraryOwnedDetailsResetPayloadBuilder? ownedDetailsResetPayloadBuilder;

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

  UpdateOwnedItemCommand buildIndexUpdateCommand({
    required String ownedItemId,
    required int indexNumber,
  }) {
    final builder = ownedIndexUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned index update builder is registered.');
    }
    return UpdateOwnedItemCommand(
      ownedItemId: ownedItemId,
      payload: builder(ownedItemId, indexNumber),
    );
  }

  UpdateOwnedItemCommand buildConditionGradeUpdateCommand({
    required String ownedItemId,
    required String? condition,
    required String? grade,
  }) {
    final builder = ownedConditionGradeUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError(
        'No typed Owned condition/grade update builder is registered.',
      );
    }
    return UpdateOwnedItemCommand(
      ownedItemId: ownedItemId,
      payload: builder(ownedItemId, condition, grade),
    );
  }

  UpdateOwnedItemCommand buildBulkUpdateCommand({
    required String ownedItemId,
    required String? condition,
    required String? grade,
    required String? locationId,
    required String? tags,
  }) {
    final builder = ownedBulkUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned bulk update builder is registered.');
    }
    return UpdateOwnedItemCommand(
      ownedItemId: ownedItemId,
      payload: builder(
        ownedItemId,
        condition,
        grade,
        locationId,
        tags,
      ),
    );
  }

  UpdateOwnedItemCommand buildPersonalDetailsUpdateCommand({
    required String ownedItemId,
    required DateTime? purchaseDate,
    required int? pricePaidCents,
    required String? currency,
    required String? personalNotes,
    required String? purchaseStore,
    required bool locationChanged,
    required String? locationId,
  }) {
    final builder = ownedPersonalDetailsUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError(
        'No typed Owned personal details update builder is registered.',
      );
    }
    return UpdateOwnedItemCommand(
      ownedItemId: ownedItemId,
      payload: builder(
        ownedItemId,
        purchaseDate,
        pricePaidCents,
        currency,
        personalNotes,
        purchaseStore,
        locationChanged,
        locationId,
      ),
    );
  }

  UpdateOwnedItemCommand buildTransferUpdateCommand({
    required String ownedItemId,
    required OwnedItem updated,
    required OwnedDetailsDraft details,
  }) {
    final builder = ownedTransferUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned transfer update builder is registered.');
    }
    return UpdateOwnedItemCommand(
      ownedItemId: ownedItemId,
      payload: builder(ownedItemId, updated, details),
    );
  }

  UpdateOwnedItemCommand buildDetailsResetCommand({
    required String ownedItemId,
  }) {
    final builder = ownedDetailsResetPayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned details reset builder is registered.');
    }
    return UpdateOwnedItemCommand(
      ownedItemId: ownedItemId,
      payload: builder(),
    );
  }

  OwnedItemUpdateRequest buildUpdateCommand({
    required LibraryEditDraft session,
    required String ownedItemId,
    required LibraryEditKindDraft kindDraft,
  }) {
    return UpdateOwnedItemCommand(
      ownedItemId: ownedItemId,
      payload: kindDraft.buildOwnedUpdatePayload(
        ownedItemId: ownedItemId,
        personal: session.personal,
      ),
    );
  }
}
