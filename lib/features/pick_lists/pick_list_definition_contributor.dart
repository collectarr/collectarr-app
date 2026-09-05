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
}
