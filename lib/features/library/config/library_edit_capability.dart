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

typedef LibraryOwnedUpdatePayloadBuilder = OwnedItemUpdatePayload Function(
  OwnedItemPatchCommand<OwnedDetailsDraft> command,
);

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
    this.ownedIndexUpdatePayloadBuilder,
    this.ownedConditionGradeUpdatePayloadBuilder,
    this.ownedBulkUpdatePayloadBuilder,
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
  final LibraryOwnedIndexUpdatePayloadBuilder? ownedIndexUpdatePayloadBuilder;
  final LibraryOwnedConditionGradeUpdatePayloadBuilder?
      ownedConditionGradeUpdatePayloadBuilder;
  final LibraryOwnedBulkUpdatePayloadBuilder? ownedBulkUpdatePayloadBuilder;

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
    OwnedItemPatchCommand<OwnedDetailsDraft> command,
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
