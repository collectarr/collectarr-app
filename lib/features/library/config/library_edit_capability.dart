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
