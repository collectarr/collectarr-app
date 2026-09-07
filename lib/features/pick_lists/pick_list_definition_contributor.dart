import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';

typedef PickListOwnedValueCounter = Future<int> Function(
  LocalDatabase db,
  String semanticName,
  String normalizedValue,
);

typedef PickListOwnedMergePreviewer = Future<PickListOwnedMergeResult> Function(
  LocalDatabase db,
  String semanticName,
  Set<String> normalizedSourceValues,
);

typedef PickListOwnedMerger = Future<void> Function(
  LocalDatabase db,
  String semanticName,
  Set<String> normalizedSourceValues,
  String targetValue,
);

final class PickListOwnedMergeResult {
  const PickListOwnedMergeResult({
    required this.affectedCount,
    required this.sampleValues,
  });

  final int affectedCount;
  final List<String> sampleValues;
}

/// Counts a semantic value from a kind-owned collection.
///
/// The host owns only matching mechanics. The [valuesFrom] callback remains
/// inside the kind and is the only code that knows how its owned model stores
/// a value.
Future<int> countPickListOwnedValues<T>({
  required Future<List<T>> items,
  required String normalizedValue,
  required Iterable<String?> Function(T item) valuesFrom,
}) async {
  var count = 0;
  for (final item in await items) {
    final values = valuesFrom(item);
    if (values.any(
      (value) =>
          value != null && normalizePickListValue(value) == normalizedValue,
    )) {
      count++;
    }
  }
  return count;
}

Future<PickListOwnedMergeResult> previewPickListOwnedMerge<T>({
  required Future<List<T>> items,
  required String Function(T item) idFrom,
  required Iterable<String?> Function(T item) valuesFrom,
  required Set<String> normalizedSourceValues,
}) async {
  var affectedCount = 0;
  final sampleValues = <String>[];
  for (final item in await items) {
    final matches = valuesFrom(item).any(
      (value) =>
          value != null &&
          normalizedSourceValues.contains(normalizePickListValue(value)),
    );
    if (!matches) continue;
    affectedCount++;
    if (sampleValues.length < 5) sampleValues.add(idFrom(item));
  }
  return PickListOwnedMergeResult(
    affectedCount: affectedCount,
    sampleValues: sampleValues,
  );
}

Future<void> applyPickListOwnedMerge<T>({
  required Future<List<T>> items,
  required Iterable<String?> Function(T item) valuesFrom,
  required T Function(
          T item, Set<String> normalizedSourceValues, String targetValue)
      replaceValue,
  required Future<void> Function(T item) save,
  required Set<String> normalizedSourceValues,
  required String targetValue,
}) async {
  for (final item in await items) {
    final matches = valuesFrom(item).any(
      (value) =>
          value != null &&
          normalizedSourceValues.contains(normalizePickListValue(value)),
    );
    if (matches) {
      await save(replaceValue(item, normalizedSourceValues, targetValue));
    }
  }
}

String? replacePickListDelimitedValue(
  String? raw,
  Set<String> normalizedSourceValues,
  String targetValue,
) {
  if (raw == null || raw.trim().isEmpty) return raw;
  final values = raw
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .map(
        (value) =>
            normalizedSourceValues.contains(normalizePickListValue(value))
                ? targetValue
                : value,
      )
      .toList(growable: false);
  final replaced = values.join(', ');
  return replaced == raw ? raw : replaced;
}

/// Projects scalar or multi-value serialized fields into pick-list values.
///
/// This is a serialization-boundary helper only. It does not assign meaning
/// to any field key; the owning kind selects the key before calling it.
Iterable<String?> pickListTextValues(Object? value) sync* {
  if (value is String) {
    yield value;
    return;
  }
  if (value is Iterable) {
    for (final item in value) {
      if (item is String) yield item;
    }
  }
}

/// Kind-owned vocabulary definitions exposed to the generic pick-list host.
///
/// The host only receives structural pick-list definitions. It never imports a
/// concrete kind or reads the kind's metadata model.
abstract interface class PickListDefinitionContributor {
  CatalogMediaKind get kind;

  Iterable<PickListDefinition> get definitions;

  Future<int> countOwnedValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  );

  Future<PickListOwnedMergeResult> previewOwnedMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  );

  Future<void> applyOwnedMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  );

  /// Projects catalog metadata into values that the generic pick-list store
  /// may capture. The contributor owns the metadata interpretation.
  Iterable<PickListCatalogValues> catalogValues(Iterable<Object?> metadata);
}

/// Structural output of a kind-owned catalog vocabulary projection.
final class PickListCatalogValues {
  const PickListCatalogValues({required this.listName, required this.values});

  final String listName;
  final Iterable<String?> values;
}

final class VocabularyPickListDefinitionContributor
    implements PickListDefinitionContributor {
  const VocabularyPickListDefinitionContributor({
    required this.kind,
    required this.vocabularies,
    this.ownedValueCounter,
    required this.ownedMergePreviewer,
    required this.ownedMerger,
  });

  @override
  final CatalogMediaKind kind;

  final List<VocabularyDefinition<dynamic>> vocabularies;

  final PickListOwnedValueCounter? ownedValueCounter;
  final PickListOwnedMergePreviewer ownedMergePreviewer;
  final PickListOwnedMerger ownedMerger;

  @override
  Future<int> countOwnedValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  ) {
    return ownedValueCounter?.call(db, semanticName, normalizedValue) ??
        Future.value(0);
  }

  @override
  Future<PickListOwnedMergeResult> previewOwnedMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  ) {
    return ownedMergePreviewer(db, semanticName, normalizedSourceValues);
  }

  @override
  Future<void> applyOwnedMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    return ownedMerger(db, semanticName, normalizedSourceValues, targetValue);
  }

  @override
  Iterable<PickListDefinition> get definitions => [
        for (final vocabulary in vocabularies)
          PickListDefinition.fromVocabulary(
            vocabulary: vocabulary,
            mediaKind: kind.apiValue,
          ),
      ];

  @override
  Iterable<PickListCatalogValues> catalogValues(
    Iterable<Object?> metadata,
  ) sync* {
    final metadataList = metadata.toList(growable: false);
    for (final vocabulary in vocabularies) {
      final valuesFrom = vocabulary.valuesFrom;
      if (valuesFrom == null) continue;

      final values = <String?>[];
      for (final item in metadataList) {
        values.addAll(valuesFrom(item));
      }
      yield PickListCatalogValues(listName: vocabulary.key, values: values);
    }
  }
}
