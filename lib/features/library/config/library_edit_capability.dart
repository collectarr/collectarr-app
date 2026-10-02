import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/collection/commands/collection_item_commands.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_collection_item_semantics.dart';
import 'package:collectarr_app/features/library/config/library_core_correction_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_collection_item_dispatch.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

export 'package:collectarr_app/features/library/config/library_chrome_config.dart';
export 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
export 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
export 'package:collectarr_app/features/library/config/collection_item_update_payload.dart';
export 'package:collectarr_app/features/library/config/library_collection_item_semantics.dart';
export 'package:collectarr_app/features/library/config/library_core_correction_capability.dart';

typedef LibraryEditSessionFactory = LibraryEditSessionBundle Function({
  required CatalogSearchCandidate item,
  LibraryCollectionItemDispatch? collectionItemDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
});

typedef LibraryOwnedIndexUpdatePayloadBuilder = CollectionItemUpdatePayload Function(
    CollectionItemRef collectionItemRef, int indexNumber);

typedef LibraryOwnedConditionValueUpdatePayloadBuilder = CollectionItemUpdatePayload
    Function(CollectionItemRef collectionItemRef, String? condition, String? collectionValue);

typedef LibraryOwnedCollectionValueReader = String? Function(
  LibraryCollectionItemDispatch? collectionItem,
);

typedef LibraryOwnedFormatHint = ({String? format, String? label});

typedef LibraryOwnedFormatHintResolver = LibraryOwnedFormatHint Function(
  CatalogSearchCandidate item,
);

typedef LibraryOwnedBulkUpdatePayloadBuilder = CollectionItemUpdatePayload Function(
  CollectionItemRef collectionItemRef,
  String? condition,
  String? collectionValue,
  String? locationId,
  String? tags,
);

typedef LibraryOwnedPersonalDetailsUpdatePayloadBuilder = CollectionItemUpdatePayload
    Function(
  CollectionItemRef collectionItemRef,
  DateTime? purchaseDate,
  int? pricePaidCents,
  String? currency,
  String? personalNotes,
  String? purchaseStore,
  bool locationChanged,
  String? locationId,
);

typedef LibraryOwnedTransferUpdatePayloadBuilder = CollectionItemUpdatePayload
    Function(
  CollectionItemRef collectionItemRef,
  Object updated,
);

typedef LibraryOwnedDetailsResetPayloadBuilder = CollectionItemUpdatePayload
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

  String? readOwnedCollectionValue(LibraryCollectionItemDispatch? collectionItem) =>
      ownedCollectionValueReader(collectionItem);

  LibraryOwnedFormatHint resolveOwnedFormatHint(
    CatalogSearchCandidate item,
  ) =>
      ownedFormatHintResolver(item);

  bool? resolveOwnedDigitalFlag(
    CollectionItemSummary? collectionItem,
    List<LibraryAddReleaseOption> releases, {
    String? fallbackFormat,
    String? fallbackLabel,
    Iterable<PhysicalMediaFormat> formats = const [],
  }) {
    return ownedDigitalFlagResolver(
      collectionItem,
      releases,
      fallbackFormat: fallbackFormat,
      fallbackLabel: fallbackLabel,
      formats: formats,
    );
  }

  UpdateCollectionItemCommand buildIndexUpdateCommand({
    required CollectionItemRef collectionItemRef,
    required int indexNumber,
  }) {
    final builder = ownedIndexUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned index update builder is registered.');
    }
    return UpdateCollectionItemCommand(
      collectionItemRef: collectionItemRef,
      payload: builder(collectionItemRef, indexNumber),
    );
  }

  UpdateCollectionItemCommand buildConditionValueUpdateCommand({
    required CollectionItemRef collectionItemRef,
    required String? condition,
    required String? collectionValue,
  }) {
    final builder = ownedConditionValueUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError(
        'No typed Owned condition/value update builder is registered.',
      );
    }
    return UpdateCollectionItemCommand(
      collectionItemRef: collectionItemRef,
      payload: builder(collectionItemRef, condition, collectionValue),
    );
  }

  UpdateCollectionItemCommand buildBulkUpdateCommand({
    required CollectionItemRef collectionItemRef,
    required String? condition,
    required String? collectionValue,
    required String? locationId,
    required String? tags,
  }) {
    final builder = ownedBulkUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned bulk update builder is registered.');
    }
    return UpdateCollectionItemCommand(
      collectionItemRef: collectionItemRef,
      payload: builder(
        collectionItemRef,
        condition,
        collectionValue,
        locationId,
        tags,
      ),
    );
  }

  UpdateCollectionItemCommand buildPersonalDetailsUpdateCommand({
    required CollectionItemRef collectionItemRef,
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
    return UpdateCollectionItemCommand(
      collectionItemRef: collectionItemRef,
      payload: builder(
        collectionItemRef,
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

  UpdateCollectionItemCommand buildTransferUpdateCommand({
    required CollectionItemRef collectionItemRef,
    required Object updated,
  }) {
    final builder = ownedTransferUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned transfer update builder is registered.');
    }
    return UpdateCollectionItemCommand(
      collectionItemRef: collectionItemRef,
      payload: builder(collectionItemRef, updated),
    );
  }

  UpdateCollectionItemCommand buildDetailsResetCommand({
    required CollectionItemRef collectionItemRef,
  }) {
    final builder = ownedDetailsResetPayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Owned details reset builder is registered.');
    }
    return UpdateCollectionItemCommand(
      collectionItemRef: collectionItemRef,
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
    required this.coreCorrectionTargetResolver,
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
  final LibraryCoreCorrectionTargetResolver coreCorrectionTargetResolver;
  final LibraryOwnedEditCapability owned;
}
