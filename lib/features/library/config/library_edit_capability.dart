import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

export 'package:collectarr_app/features/library/config/library_chrome_config.dart';
export 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
export 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
export 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
export 'package:collectarr_app/features/library/config/library_owned_copy_semantics.dart';

typedef LibraryEditSessionFactory = LibraryEditSessionBundle Function({
  required CatalogSearchCandidate item,
  LibraryOwnedItemDispatch? ownedItemDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
});

typedef LibraryOwnedIndexUpdatePayloadBuilder = OwnedItemUpdatePayload Function(
    OwnedItemRef ownedRef, int indexNumber);

typedef LibraryOwnedConditionValueUpdatePayloadBuilder = OwnedItemUpdatePayload
    Function(OwnedItemRef ownedRef, String? condition, String? collectionValue);

typedef LibraryOwnedCollectionValueReader = String? Function(
  LibraryOwnedItemDispatch? ownedItem,
);

typedef LibraryOwnedFormatHint = ({String? format, String? label});

typedef LibraryOwnedFormatHintResolver = LibraryOwnedFormatHint Function(
  CatalogSearchCandidate item,
);

typedef LibraryOwnedBulkUpdatePayloadBuilder = OwnedItemUpdatePayload Function(
  OwnedItemRef ownedRef,
  String? condition,
  String? collectionValue,
  String? locationId,
  String? tags,
);

typedef LibraryOwnedPersonalDetailsUpdatePayloadBuilder = OwnedItemUpdatePayload
    Function(
  OwnedItemRef ownedRef,
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
  OwnedItemRef ownedRef,
  Object updated,
);

typedef LibraryOwnedDetailsResetPayloadBuilder = OwnedItemUpdatePayload
    Function();

final class LibraryEntityEditContributor {
  const LibraryEntityEditContributor({
    required this.scope,
    required this.builder,
  });

  final LibraryEntityScope scope;
  final LibraryEditDialogBuilder builder;
}

final class LibraryEntityEditRegistry {
  const LibraryEntityEditRegistry({
    required this.contributors,
  });

  final List<LibraryEntityEditContributor> contributors;

  LibraryEditDialogBuilder? builderForScope(LibraryEntityScope scope) {
    for (final contributor in contributors) {
      if (contributor.scope == scope) return contributor.builder;
    }
    return null;
  }
}

/// Presentation-only configuration for the shared edit host.
///
/// This object contains no draft construction or Owned mutation behavior.
final class LibraryEditPresentationCapability {
  const LibraryEditPresentationCapability({
    required this.editRegistry,
    required this.presentation,
    this.editChrome = const LibraryEditChromeConfig(),
    this.vocabularies,
    required this.conditions,
    this.collectionValueOptions = const [],
    required this.defaultCondition,
    required this.defaultCollectionValue,
  });

  final LibraryEntityEditRegistry editRegistry;
  final LibraryEditPresentation presentation;
  final LibraryEditChromeConfig editChrome;
  final LibraryKindVocabularyCapability? vocabularies;
  final List<String> conditions;
  final List<String> collectionValueOptions;
  final String defaultCondition;
  final String defaultCollectionValue;

  bool get hasConditionPickList => conditions.isNotEmpty;
  bool get hasCollectionValuePickList => collectionValueOptions.isNotEmpty;
}

/// Kind-owned draft construction and typed edit-result assembly.
final class LibraryEditSessionCapability {
  const LibraryEditSessionCapability({this.createSession});

  final LibraryEditSessionFactory? createSession;
}

/// Kind-owned Owned field semantics and mutation payload builders.
final class LibraryOwnedEditCapability {
  const LibraryOwnedEditCapability({
    required this.ownedCollectionValueReader,
    required this.ownedDigitalFlagResolver,
    required this.ownedFormatHintResolver,
    this.ownedIndexUpdatePayloadBuilder,
    this.ownedConditionValueUpdatePayloadBuilder,
    this.ownedBulkUpdatePayloadBuilder,
    this.ownedPersonalDetailsUpdatePayloadBuilder,
    this.ownedTransferUpdatePayloadBuilder,
    this.ownedDetailsResetPayloadBuilder,
  });

  final LibraryOwnedCollectionValueReader ownedCollectionValueReader;
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

  String? readOwnedCollectionValue(LibraryOwnedItemDispatch? ownedItem) =>
      ownedCollectionValueReader(ownedItem);

  LibraryOwnedFormatHint resolveOwnedFormatHint(
    CatalogSearchCandidate item,
  ) =>
      ownedFormatHintResolver(item);

  bool? resolveOwnedDigitalFlag(
    OwnedItemSummary? ownedItem,
    List<LibraryAddReleaseOption> releases, {
    String? fallbackFormat,
    String? fallbackLabel,
    Iterable<PhysicalMediaFormat> formats = const [],
  }) {
    return ownedDigitalFlagResolver(
      ownedItem,
      releases,
      fallbackFormat: fallbackFormat,
      fallbackLabel: fallbackLabel,
      formats: formats,
    );
  }

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
      payload: builder(ownedRef, indexNumber),
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
      payload: builder(ownedRef, condition, collectionValue),
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
        ownedRef,
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
        ownedRef,
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
      payload: builder(ownedRef, updated),
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
}

/// Internal kind composition object. Consumers must select one of the three
/// narrow capabilities; this type is never exposed by the public registry.
final class LibraryEditCapabilitySet {
  LibraryEditCapabilitySet({
    required LibraryEntityEditRegistry editRegistry,
    required LibraryEditPresentation presentation,
    LibraryEditSessionFactory? createSession,
    required LibraryOwnedCollectionValueReader ownedCollectionValueReader,
    required LibraryOwnedDigitalFlagResolver ownedDigitalFlagResolver,
    required LibraryOwnedFormatHintResolver ownedFormatHintResolver,
    required List<String> conditions,
    required String defaultCondition,
    required String defaultCollectionValue,
    List<String> collectionValueOptions = const [],
    LibraryEditChromeConfig editChrome = const LibraryEditChromeConfig(),
    LibraryKindVocabularyCapability? vocabularies,
    LibraryOwnedIndexUpdatePayloadBuilder? ownedIndexUpdatePayloadBuilder,
    LibraryOwnedConditionValueUpdatePayloadBuilder?
        ownedConditionValueUpdatePayloadBuilder,
    LibraryOwnedBulkUpdatePayloadBuilder? ownedBulkUpdatePayloadBuilder,
    LibraryOwnedPersonalDetailsUpdatePayloadBuilder?
        ownedPersonalDetailsUpdatePayloadBuilder,
    LibraryOwnedTransferUpdatePayloadBuilder? ownedTransferUpdatePayloadBuilder,
    LibraryOwnedDetailsResetPayloadBuilder? ownedDetailsResetPayloadBuilder,
  })  : presentationCapability = LibraryEditPresentationCapability(
          editRegistry: editRegistry,
          presentation: presentation,
          editChrome: editChrome,
          vocabularies: vocabularies,
          conditions: conditions,
          collectionValueOptions: collectionValueOptions,
          defaultCondition: defaultCondition,
          defaultCollectionValue: defaultCollectionValue,
        ),
        session = LibraryEditSessionCapability(createSession: createSession),
        owned = LibraryOwnedEditCapability(
          ownedCollectionValueReader: ownedCollectionValueReader,
          ownedDigitalFlagResolver: ownedDigitalFlagResolver,
          ownedFormatHintResolver: ownedFormatHintResolver,
          ownedIndexUpdatePayloadBuilder: ownedIndexUpdatePayloadBuilder,
          ownedConditionValueUpdatePayloadBuilder:
              ownedConditionValueUpdatePayloadBuilder,
          ownedBulkUpdatePayloadBuilder: ownedBulkUpdatePayloadBuilder,
          ownedPersonalDetailsUpdatePayloadBuilder:
              ownedPersonalDetailsUpdatePayloadBuilder,
          ownedTransferUpdatePayloadBuilder: ownedTransferUpdatePayloadBuilder,
          ownedDetailsResetPayloadBuilder: ownedDetailsResetPayloadBuilder,
        );

  final LibraryEditPresentationCapability presentationCapability;
  final LibraryEditSessionCapability session;
  final LibraryOwnedEditCapability owned;
}
