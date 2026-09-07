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
  });

  @override
  final CatalogMediaKind kind;

  final List<VocabularyDefinition<dynamic>> vocabularies;

  final PickListOwnedValueCounter? ownedValueCounter;

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
