import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';

final class PickListEntryMergeResult {
  const PickListEntryMergeResult({
    required this.affectedCount,
    required this.sampleValues,
  });

  final int affectedCount;
  final List<String> sampleValues;
}

/// How one kind reads and rewrites the pick-list values kept on its entries.
final class PickListEntryValues<T> {
  const PickListEntryValues({
    required this.listActive,
    required this.idFrom,
    required this.valuesFrom,
    required this.replaceValue,
    required this.save,
  });

  final Future<List<T>> Function(LocalDatabase db) listActive;
  final String Function(T item) idFrom;
  final Iterable<String?> Function(T item, String semanticName) valuesFrom;
  final T Function(
    T item,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) replaceValue;
  final Future<void> Function(LocalDatabase db, T item) save;

  Future<List<String>> options(LocalDatabase db, String semanticName) async => [
        for (final item in await listActive(db))
          ...valuesFrom(item, semanticName)
              .whereType<String>()
              .where((value) => value.trim().isNotEmpty),
      ];

  /// Each entry counts once per value, however often it repeats the value.
  Future<Map<String, int>> usageCounts(
    LocalDatabase db,
    String semanticName,
  ) async {
    final counts = <String, int>{};
    for (final item in await listActive(db)) {
      final values = valuesFrom(item, semanticName)
          .whereType<String>()
          .map(normalizePickListValue)
          .where((value) => value.isNotEmpty)
          .toSet();
      for (final value in values) {
        counts[value] = (counts[value] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<PickListEntryMergeResult> previewMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  ) async {
    var affectedCount = 0;
    final sampleValues = <String>[];
    for (final item in await listActive(db)) {
      if (!_uses(item, semanticName, normalizedSourceValues)) continue;
      affectedCount++;
      if (sampleValues.length < 5) sampleValues.add(idFrom(item));
    }
    return PickListEntryMergeResult(
      affectedCount: affectedCount,
      sampleValues: sampleValues,
    );
  }

  Future<void> applyMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) async {
    for (final item in await listActive(db)) {
      if (!_uses(item, semanticName, normalizedSourceValues)) continue;
      await save(
        db,
        replaceValue(item, semanticName, normalizedSourceValues, targetValue),
      );
    }
  }

  bool _uses(T item, String semanticName, Set<String> normalizedValues) =>
      valuesFrom(item, semanticName).any(
        (value) =>
            value != null &&
            normalizedValues.contains(normalizePickListValue(value)),
      );
}

String? replacePickListDelimitedValue(
  String? raw,
  Set<String> normalizedSourceValues,
  String targetValue,
) {
  if (raw == null || raw.trim().isEmpty) return raw;
  final replaced = replacePickListValueInList(
    raw.split(','),
    normalizedSourceValues,
    targetValue,
  ).join(', ');
  return replaced == raw ? raw : replaced;
}

/// Replaces matching values in a multi-value field, trimming and dropping
/// repeated values.
List<String> replacePickListValueInList(
  Iterable<String> values,
  Set<String> normalizedSourceValues,
  String targetValue,
) {
  final seen = <String>{};
  return [
    for (final raw in values)
      if (raw.trim() case final value when value.isNotEmpty)
        if (normalizedSourceValues.contains(normalizePickListValue(value))
                ? targetValue.trim()
                : value
            case final next when next.isNotEmpty)
          if (seen.add(normalizePickListValue(next))) next,
  ];
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

/// Kind-entry vocabulary definitions exposed to the generic pick-list host.
///
/// The host only receives structural pick-list definitions. It never imports a
/// concrete kind or reads the kind's metadata model.
abstract interface class PickListDefinitionContributor {
  CatalogMediaKind get kind;

  Future<List<String>> entryOptions(LocalDatabase db, String semanticName);
  Future<Map<String, int>> entryUsageCounts(
      LocalDatabase db, String semanticName);
  Future<void> updateSortName(
      LocalDatabase db, String semanticName, String value, String? sortName);

  Iterable<PickListDefinition> get definitions;

  Future<PickListEntryMergeResult> previewEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  );

  Future<void> applyEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  );

  /// Projects catalog metadata into values that the generic pick-list store
  /// may capture. The contributor owns the metadata interpretation.
  Iterable<PickListCatalogValues> catalogValues(Iterable<Object?> metadata);
}

/// Counts catalog records whose kind-entry projection uses pick-list values.
/// Each record contributes at most one use per value, even when its metadata
/// contains the same value more than once.
Map<String, int> countPickListCatalogValuesByValue({
  required PickListDefinitionContributor contributor,
  required String listName,
  required Iterable<Object?> metadata,
  required Iterable<String> normalizedValues,
}) {
  final counts = {
    for (final value in normalizedValues)
      if (value.isNotEmpty) value: 0,
  };
  if (counts.isEmpty) return counts;

  for (final item in metadata) {
    final usedValues = <String>{};
    for (final projection in contributor.catalogValues([item])) {
      if (projection.listName != listName) continue;
      for (final value in projection.values) {
        if (value == null) continue;
        final normalized = normalizePickListValue(value);
        if (counts.containsKey(normalized)) usedValues.add(normalized);
      }
    }
    for (final value in usedValues) {
      counts[value] = counts[value]! + 1;
    }
  }
  return counts;
}

/// Structural output of a kind-entry catalog vocabulary projection.
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
    required this.entries,
    this.entrySortNameUpdater,
  });

  @override
  final CatalogMediaKind kind;

  final List<VocabularyDefinition<dynamic>> vocabularies;

  final PickListEntryValues<Object?> entries;

  final Future<void> Function(LocalDatabase db, String semanticName,
      String value, String? sortName)? entrySortNameUpdater;

  @override
  Future<List<String>> entryOptions(LocalDatabase db, String semanticName) =>
      entries.options(db, semanticName);

  @override
  Future<Map<String, int>> entryUsageCounts(
          LocalDatabase db, String semanticName) =>
      entries.usageCounts(db, semanticName);

  @override
  Future<void> updateSortName(LocalDatabase db, String semanticName,
      String value, String? sortName) async {
    await entrySortNameUpdater?.call(db, semanticName, value, sortName);
  }

  @override
  Future<PickListEntryMergeResult> previewEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  ) =>
      entries.previewMerge(db, semanticName, normalizedSourceValues);

  @override
  Future<void> applyEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) =>
      entries.applyMerge(db, semanticName, normalizedSourceValues, targetValue);

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
