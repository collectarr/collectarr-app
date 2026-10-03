import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_entry_semantics.dart';
import 'package:collectarr_app/features/library/config/library_core_correction_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

export 'package:collectarr_app/features/library/config/library_chrome_config.dart';
export 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
export 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
export 'package:collectarr_app/features/library/config/library_entry_update_payload.dart';
export 'package:collectarr_app/features/library/config/library_entry_semantics.dart';
export 'package:collectarr_app/features/library/config/library_core_correction_capability.dart';

typedef LibraryEditSessionFactory = LibraryEditSessionBundle Function({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
});

typedef LibraryEntryIndexUpdatePayloadBuilder = LibraryEntryUpdatePayload Function(
    LibraryEntryRef libraryEntryRef, int indexNumber);

typedef LibraryEntryConditionValueUpdatePayloadBuilder = LibraryEntryUpdatePayload
    Function(LibraryEntryRef libraryEntryRef, String? condition, String? collectionValue);

typedef LibraryEntryCollectionValueReader = String? Function(
  LibraryEntryDispatch? libraryEntry,
);

typedef LibraryEntryFormatHint = ({String? format, String? label});

typedef LibraryEntryFormatHintResolver = LibraryEntryFormatHint Function(
  CatalogSearchCandidate item,
);

typedef LibraryEntryBulkUpdatePayloadBuilder = LibraryEntryUpdatePayload Function(
  LibraryEntryRef libraryEntryRef,
  String? condition,
  String? collectionValue,
  String? locationId,
  String? tags,
);

typedef LibraryEntryPersonalDetailsUpdatePayloadBuilder = LibraryEntryUpdatePayload
    Function(
  LibraryEntryRef libraryEntryRef,
  DateTime? purchaseDate,
  int? pricePaidCents,
  String? currency,
  String? personalNotes,
  String? purchaseStore,
  bool locationChanged,
  String? locationId,
);

typedef LibraryEntryTransferUpdatePayloadBuilder = LibraryEntryUpdatePayload
    Function(
  LibraryEntryRef libraryEntryRef,
  Object updated,
);

typedef LibraryEntryDetailsResetPayloadBuilder = LibraryEntryUpdatePayload
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
/// This object contains no draft construction or Entry mutation behavior.
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

/// Kind-entry draft construction and typed edit-result assembly.
final class LibraryEditSessionCapability {
  const LibraryEditSessionCapability({this.createSession});

  final LibraryEditSessionFactory? createSession;
}

/// Kind-entry Entry field semantics and mutation payload builders.
final class LibraryEntryEditCapability {
  const LibraryEntryEditCapability({
    required this.entryCollectionValueReader,
    required this.entryDigitalFlagResolver,
    required this.entryFormatHintResolver,
    this.entryIndexUpdatePayloadBuilder,
    this.entryConditionValueUpdatePayloadBuilder,
    this.entryBulkUpdatePayloadBuilder,
    this.entryPersonalDetailsUpdatePayloadBuilder,
    this.entryTransferUpdatePayloadBuilder,
    this.entryDetailsResetPayloadBuilder,
  });

  final LibraryEntryCollectionValueReader entryCollectionValueReader;
  final LibraryEntryDigitalFlagResolver entryDigitalFlagResolver;
  final LibraryEntryFormatHintResolver entryFormatHintResolver;
  final LibraryEntryIndexUpdatePayloadBuilder? entryIndexUpdatePayloadBuilder;
  final LibraryEntryConditionValueUpdatePayloadBuilder?
      entryConditionValueUpdatePayloadBuilder;
  final LibraryEntryBulkUpdatePayloadBuilder? entryBulkUpdatePayloadBuilder;
  final LibraryEntryPersonalDetailsUpdatePayloadBuilder?
      entryPersonalDetailsUpdatePayloadBuilder;
  final LibraryEntryTransferUpdatePayloadBuilder?
      entryTransferUpdatePayloadBuilder;
  final LibraryEntryDetailsResetPayloadBuilder? entryDetailsResetPayloadBuilder;

  String? readEntryCollectionValue(LibraryEntryDispatch? libraryEntry) =>
      entryCollectionValueReader(libraryEntry);

  LibraryEntryFormatHint resolveEntryFormatHint(
    CatalogSearchCandidate item,
  ) =>
      entryFormatHintResolver(item);

  bool? resolveEntryDigitalFlag(
    LibraryEntrySummary? libraryEntry,
    {
    String? fallbackFormat,
    String? fallbackLabel,
    Iterable<PhysicalMediaFormat> formats = const [],
  }) {
    return entryDigitalFlagResolver(
      libraryEntry,
      fallbackFormat: fallbackFormat,
      fallbackLabel: fallbackLabel,
      formats: formats,
    );
  }

  UpdateLibraryEntryCommand buildIndexUpdateCommand({
    required LibraryEntryRef libraryEntryRef,
    required int indexNumber,
  }) {
    final builder = entryIndexUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Entry index update builder is registered.');
    }
    return UpdateLibraryEntryCommand(
      libraryEntryRef: libraryEntryRef,
      payload: builder(libraryEntryRef, indexNumber),
    );
  }

  UpdateLibraryEntryCommand buildConditionValueUpdateCommand({
    required LibraryEntryRef libraryEntryRef,
    required String? condition,
    required String? collectionValue,
  }) {
    final builder = entryConditionValueUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError(
        'No typed Entry condition/value update builder is registered.',
      );
    }
    return UpdateLibraryEntryCommand(
      libraryEntryRef: libraryEntryRef,
      payload: builder(libraryEntryRef, condition, collectionValue),
    );
  }

  UpdateLibraryEntryCommand buildBulkUpdateCommand({
    required LibraryEntryRef libraryEntryRef,
    required String? condition,
    required String? collectionValue,
    required String? locationId,
    required String? tags,
  }) {
    final builder = entryBulkUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Entry bulk update builder is registered.');
    }
    return UpdateLibraryEntryCommand(
      libraryEntryRef: libraryEntryRef,
      payload: builder(
        libraryEntryRef,
        condition,
        collectionValue,
        locationId,
        tags,
      ),
    );
  }

  UpdateLibraryEntryCommand buildPersonalDetailsUpdateCommand({
    required LibraryEntryRef libraryEntryRef,
    required DateTime? purchaseDate,
    required int? pricePaidCents,
    required String? currency,
    required String? personalNotes,
    required String? purchaseStore,
    required bool locationChanged,
    required String? locationId,
  }) {
    final builder = entryPersonalDetailsUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError(
        'No typed Entry personal details update builder is registered.',
      );
    }
    return UpdateLibraryEntryCommand(
      libraryEntryRef: libraryEntryRef,
      payload: builder(
        libraryEntryRef,
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

  UpdateLibraryEntryCommand buildTransferUpdateCommand({
    required LibraryEntryRef libraryEntryRef,
    required Object updated,
  }) {
    final builder = entryTransferUpdatePayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Entry transfer update builder is registered.');
    }
    return UpdateLibraryEntryCommand(
      libraryEntryRef: libraryEntryRef,
      payload: builder(libraryEntryRef, updated),
    );
  }

  UpdateLibraryEntryCommand buildDetailsResetCommand({
    required LibraryEntryRef libraryEntryRef,
  }) {
    final builder = entryDetailsResetPayloadBuilder;
    if (builder == null) {
      throw StateError('No typed Entry details reset builder is registered.');
    }
    return UpdateLibraryEntryCommand(
      libraryEntryRef: libraryEntryRef,
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
    required LibraryEntryCollectionValueReader entryCollectionValueReader,
    required LibraryEntryDigitalFlagResolver entryDigitalFlagResolver,
    required LibraryEntryFormatHintResolver entryFormatHintResolver,
    required List<String> conditions,
    required String defaultCondition,
    required String defaultCollectionValue,
    List<String> collectionValueOptions = const [],
    LibraryEditChromeConfig editChrome = const LibraryEditChromeConfig(),
    LibraryKindVocabularyCapability? vocabularies,
    LibraryEntryIndexUpdatePayloadBuilder? entryIndexUpdatePayloadBuilder,
    LibraryEntryConditionValueUpdatePayloadBuilder?
        entryConditionValueUpdatePayloadBuilder,
    LibraryEntryBulkUpdatePayloadBuilder? entryBulkUpdatePayloadBuilder,
    LibraryEntryPersonalDetailsUpdatePayloadBuilder?
        entryPersonalDetailsUpdatePayloadBuilder,
    LibraryEntryTransferUpdatePayloadBuilder? entryTransferUpdatePayloadBuilder,
    LibraryEntryDetailsResetPayloadBuilder? entryDetailsResetPayloadBuilder,
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
        entry = LibraryEntryEditCapability(
          entryCollectionValueReader: entryCollectionValueReader,
          entryDigitalFlagResolver: entryDigitalFlagResolver,
          entryFormatHintResolver: entryFormatHintResolver,
          entryIndexUpdatePayloadBuilder: entryIndexUpdatePayloadBuilder,
          entryConditionValueUpdatePayloadBuilder:
              entryConditionValueUpdatePayloadBuilder,
          entryBulkUpdatePayloadBuilder: entryBulkUpdatePayloadBuilder,
          entryPersonalDetailsUpdatePayloadBuilder:
              entryPersonalDetailsUpdatePayloadBuilder,
          entryTransferUpdatePayloadBuilder: entryTransferUpdatePayloadBuilder,
          entryDetailsResetPayloadBuilder: entryDetailsResetPayloadBuilder,
        );

  final LibraryEditPresentationCapability presentationCapability;
  final LibraryEditSessionCapability session;
  final LibraryCoreCorrectionTargetResolver coreCorrectionTargetResolver;
  final LibraryEntryEditCapability entry;
}
