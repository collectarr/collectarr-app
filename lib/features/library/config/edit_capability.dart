import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/config/chrome_config.dart';
import 'package:collectarr_app/features/library/config/edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/kind_vocabulary_capability.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/config/entry_semantics.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/shell_state.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/config/chrome_config.dart';
export 'package:collectarr_app/features/library/config/edit_presentation_models.dart';
export 'package:collectarr_app/features/library/config/kind_vocabulary_capability.dart';
export 'package:collectarr_app/features/library/config/entry_update_payload.dart';
export 'package:collectarr_app/features/library/config/entry_semantics.dart';

typedef LibraryEditSessionFactory = LibraryEditSessionBundle Function({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
});

typedef LibraryEntryIndexUpdatePayloadBuilder = LibraryEntryUpdatePayload
    Function(LibraryEntryRef libraryEntryRef, int indexNumber);

typedef LibraryEntryConditionValueUpdatePayloadBuilder
    = LibraryEntryUpdatePayload Function(LibraryEntryRef libraryEntryRef,
        String? condition, String? collectionValue);

typedef LibraryEntryCollectionValueReader = String? Function(
  LibraryEntryDispatch? libraryEntry,
);

typedef LibraryEntryFormatHint = ({String? format, String? label});

typedef LibraryEntryFormatHintResolver = LibraryEntryFormatHint Function(
  CatalogSearchCandidate item,
);

typedef LibraryEntryBulkUpdatePayloadBuilder = LibraryEntryUpdatePayload
    Function(
  LibraryEntryRef libraryEntryRef,
  String? condition,
  String? collectionValue,
  String? locationId,
  List<String>? tags,
);

typedef LibraryEntryPersonalDetailsUpdatePayloadBuilder
    = LibraryEntryUpdatePayload Function(
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

final class LibraryTargetEditRegistry {
  const LibraryTargetEditRegistry({
    required this.catalogItem,
    required this.libraryEntry,
  });

  final LibraryEditDialogBuilder catalogItem;
  final LibraryEditDialogBuilder libraryEntry;

  LibraryEditDialogBuilder builderForTarget(LibraryTargetRef? target) =>
      target is EntryTargetRef ? libraryEntry : catalogItem;
}

/// A kind control offered by Pre-fill Settings, such as completeness with
/// its packaging, under the [id] and [label] its Pre-fill fields list shows.
final class LibraryPrefillField {
  const LibraryPrefillField(
      {required this.id,
      required this.label,
      required this.field,
      this.group = 'Value',
      this.shownByDefault = true,
      this.fullWidth = true,
      List<String>? keys})
      : _keys = keys;

  final String id;
  final String label;
  final Widget field;

  /// The Pre-fill fields group it is listed under, such as Main or Edition.
  final String group;

  /// False leaves it out until chosen in Pre-fill fields.
  final bool shownByDefault;

  /// False takes one of the two columns instead of both.
  final bool fullWidth;
  final List<String>? _keys;

  /// The draft values the control sets; by default only [id].
  List<String> get keys => _keys ?? [id];
}

/// Kind controls that lead Pre-fill Settings, bound to the pre-fill draft.
typedef LibraryPrefillFieldsBuilder = List<LibraryPrefillField> Function(
    LibraryEntryEditDraft draft);

/// Catalog values Pre-fill Settings gives new items, keyed as the kind's
/// catalog data; a cleared value is removed.
final class LibraryPrefillCatalogDraft extends ChangeNotifier {
  LibraryPrefillCatalogDraft(Map<String, Object?> values)
      : _values = Map.of(values);

  final Map<String, Object?> _values;
  final _controllers = <String, TextEditingController>{};

  Map<String, Object?> get values => Map.unmodifiable(_values);

  String text(String key) =>
      _values[key] is String ? _values[key]! as String : '';

  List<String> list(String key) => [
        if (_values[key] case final List<Object?> values)
          for (final value in values)
            if (value is String) value,
      ];

  void set(String key, Object? value) {
    final empty = value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is List && value.isEmpty);
    if (empty ? _values.remove(key) == null : _values[key] == value) return;
    if (!empty) _values[key] = value is String ? value.trim() : value;
    notifyListeners();
  }

  void clear() {
    if (_values.isEmpty) return;
    _values.clear();
    for (final controller in _controllers.values) {
      controller.clear();
    }
    notifyListeners();
  }

  /// A text controller kept for the field [id] while the dialog is open.
  TextEditingController controller(String id, String initialValue) =>
      _controllers.putIfAbsent(
          id, () => TextEditingController(text: initialValue));

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// Catalog fields Pre-fill Settings offers, such as Series or Region; each
/// field's keys are catalog data keys, filled on new items that lack them.
typedef LibraryPrefillCatalogFieldsBuilder = List<LibraryPrefillField> Function(
    BuildContext context, LibraryPrefillCatalogDraft draft);

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
    this.prefillFields,
    this.prefillCatalogFields,
    this.prefillPriceFromCover = false,
  });

  /// When set, Pre-fill Settings leads with these controls and shows Owner,
  /// Quantity and Tags instead of Condition until other fields are chosen,
  /// as in the reference Games pre-fill.
  final LibraryPrefillFieldsBuilder? prefillFields;

  /// Catalog fields Pre-fill Settings also offers, off until chosen.
  final LibraryPrefillCatalogFieldsBuilder? prefillCatalogFields;

  /// Pre-fill Settings also offers Fill with Cover Price and Discount %.
  final bool prefillPriceFromCover;

  final LibraryTargetEditRegistry editRegistry;
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
    LibraryEntrySummary? libraryEntry, {
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
    required List<String>? tags,
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
    required LibraryTargetEditRegistry editRegistry,
    required LibraryEditPresentation presentation,
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
    LibraryPrefillFieldsBuilder? prefillFields,
    LibraryPrefillCatalogFieldsBuilder? prefillCatalogFields,
    bool prefillPriceFromCover = false,
  })  : presentationCapability = LibraryEditPresentationCapability(
          prefillFields: prefillFields,
          prefillCatalogFields: prefillCatalogFields,
          prefillPriceFromCover: prefillPriceFromCover,
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
  final LibraryEntryEditCapability entry;
}
