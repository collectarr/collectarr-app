import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

export 'package:collectarr_app/features/library/config/library_chrome_config.dart';
export 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
export 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
export 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
export 'package:collectarr_app/features/library/config/library_owned_copy_semantics.dart';

typedef LibraryEditKindDraftFactory = LibraryEditKindDraft Function({
  required CatalogSearchCandidate item,
  LibraryOwnedItemDispatch? ownedItemDispatch,
  TrackingLifecycle? trackingLifecycle,
  required TextControllerGroup textControllers,
});

typedef LibraryOwnedIndexUpdatePayloadBuilder = OwnedItemUpdatePayload<Object?>
    Function(String ownedItemId, int indexNumber);

typedef LibraryOwnedConditionValueUpdatePayloadBuilder
    = OwnedItemUpdatePayload<Object?> Function(
        String ownedItemId, String? condition, String? collectionValue);

typedef LibraryOwnedCollectionValueReader = String? Function(
  OwnedItemSummary? ownedItem,
);

typedef LibraryOwnedFormatHint = ({String? format, String? label});

typedef LibraryOwnedFormatHintResolver = LibraryOwnedFormatHint Function(
  CatalogSearchCandidate item,
);

typedef LibraryOwnedBulkUpdatePayloadBuilder = OwnedItemUpdatePayload<Object?>
    Function(
  String ownedItemId,
  String? condition,
  String? collectionValue,
  String? locationId,
  String? tags,
);

typedef LibraryOwnedPersonalDetailsUpdatePayloadBuilder
    = OwnedItemUpdatePayload<Object?> Function(
  String ownedItemId,
  DateTime? purchaseDate,
  int? pricePaidCents,
  String? currency,
  String? personalNotes,
  String? purchaseStore,
  bool locationChanged,
  String? locationId,
);

typedef LibraryOwnedTransferUpdatePayloadBuilder
    = OwnedItemUpdatePayload<Object?> Function(
  String ownedItemId,
  Object updated,
);

typedef LibraryOwnedDetailsResetPayloadBuilder = OwnedItemUpdatePayload<Object?>
    Function();

/// Encapsulates edit dialogs, edit chrome, field config, condition/value options,
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
    this.collectionValueOptions = const [],
    required this.ownedCollectionValueReader,
    required this.defaultCondition,
    required this.defaultCollectionValue,
    required this.createDraft,
    required this.ownedDigitalFlagResolver,
    required this.ownedFormatHintResolver,
    this.ownedIndexUpdatePayloadBuilder,
    this.ownedConditionValueUpdatePayloadBuilder,
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
  final List<String> collectionValueOptions;
  final LibraryOwnedCollectionValueReader ownedCollectionValueReader;
  final String defaultCondition;
  final String defaultCollectionValue;
  final LibraryEditKindDraftFactory createDraft;
  final LibraryOwnedDigitalFlagResolver ownedDigitalFlagResolver;
  final LibraryOwnedFormatHintResolver ownedFormatHintResolver;
  final LibraryOwnedIndexUpdatePayloadBuilder? ownedIndexUpdatePayloadBuilder;
  final LibraryOwnedConditionValueUpdatePayloadBuilder?
      ownedConditionValueUpdatePayloadBuilder;
  final LibraryOwnedBulkUpdatePayloadBuilder? ownedBulkUpdatePayloadBuilder;
  final LibraryOwnedPersonalDetailsUpdatePayloadBuilder?
      ownedPersonalDetailsUpdatePayloadBuilder;
  final LibraryOwnedTransferUpdatePayloadBuilder?
      ownedTransferUpdatePayloadBuilder;
  final LibraryOwnedDetailsResetPayloadBuilder? ownedDetailsResetPayloadBuilder;

  bool get hasConditionPickList => conditions.isNotEmpty;
  bool get hasCollectionValuePickList => collectionValueOptions.isNotEmpty;

  String? readOwnedCollectionValue(OwnedItemSummary? ownedItem) =>
      ownedCollectionValueReader(ownedItem);

  LibraryOwnedFormatHint resolveOwnedFormatHint(
    CatalogSearchCandidate item,
  ) =>
      ownedFormatHintResolver(item);

  bool? resolveOwnedDigitalFlag(
    OwnedItemSummary? ownedItem,
    List<CatalogEditionDto> editions, {
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

  JsonEncodable buildDetailsDraft(LibraryEditKindDraft kindDraft) =>
      kindDraft.toDetailsDraft();

  UpdateOwnedItemCommand buildIndexUpdateCommand({
    required OwnedItemRef ownedRef,
    required int indexNumber,
  }) {
    final builder = ownedIndexUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned index update builder is registered.');
    }
    return UpdateOwnedItemCommand(
      ownedRef: ownedRef,
      payload: builder(ownedRef.id.value, indexNumber),
    );
  }

  UpdateOwnedItemCommand buildConditionValueUpdateCommand({
    required OwnedItemRef ownedRef,
    required String? condition,
    required String? collectionValue,
  }) {
    final builder = ownedConditionValueUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError(
        'No typed Owned condition/value update builder is registered.',
      );
    }
    return UpdateOwnedItemCommand(
      ownedRef: ownedRef,
      payload: builder(ownedRef.id.value, condition, collectionValue),
    );
  }

  UpdateOwnedItemCommand buildBulkUpdateCommand({
    required OwnedItemRef ownedRef,
    required String? condition,
    required String? collectionValue,
    required String? locationId,
    required String? tags,
  }) {
    final builder = ownedBulkUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned bulk update builder is registered.');
    }
    return UpdateOwnedItemCommand(
      ownedRef: ownedRef,
      payload: builder(
        ownedRef.id.value,
        condition,
        collectionValue,
        locationId,
        tags,
      ),
    );
  }

  UpdateOwnedItemCommand buildPersonalDetailsUpdateCommand({
    required OwnedItemRef ownedRef,
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
      ownedRef: ownedRef,
      payload: builder(
        ownedRef.id.value,
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
    required OwnedItemRef ownedRef,
    required Object updated,
  }) {
    final builder = ownedTransferUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned transfer update builder is registered.');
    }
    return UpdateOwnedItemCommand(
      ownedRef: ownedRef,
      payload: builder(ownedRef.id.value, updated),
    );
  }

  UpdateOwnedItemCommand buildDetailsResetCommand({
    required OwnedItemRef ownedRef,
  }) {
    final builder = ownedDetailsResetPayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned details reset builder is registered.');
    }
    return UpdateOwnedItemCommand(
      ownedRef: ownedRef,
      payload: builder(),
    );
  }

  OwnedItemUpdateRequest buildUpdateCommand({
    required LibraryEditDraft session,
    required OwnedItemRef ownedRef,
    required LibraryEditKindDraft kindDraft,
  }) {
    return UpdateOwnedItemCommand(
      ownedRef: ownedRef,
      payload: kindDraft.buildOwnedUpdatePayload(
        ownedItemId: ownedRef.id.value,
        personal: session.personal,
      ),
    );
  }
}
