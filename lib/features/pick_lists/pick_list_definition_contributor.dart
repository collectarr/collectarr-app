import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';

/// Kind-owned vocabulary definitions exposed to the generic pick-list host.
///
/// The host only receives structural pick-list definitions. It never imports a
/// concrete kind or reads the kind's metadata model.
abstract interface class PickListDefinitionContributor {
  CatalogMediaKind get kind;

  Iterable<PickListDefinition> get definitions;

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
  });

  @override
  final CatalogMediaKind kind;

  final List<VocabularyDefinition<dynamic>> vocabularies;

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
