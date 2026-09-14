import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';

/// Seeds only vocabulary definitions owned by a concrete kind.
///
/// Kind values are captured rather than replaced so checked-in built-ins and
/// values discovered from the seeded catalog are both available.
Future<void> seedPickLists(PickListRepository repo) async {
  for (final contributor in collectarrKindPickListDefinitionContributors) {
    if (contributor is! VocabularyPickListDefinitionContributor) continue;
    await _seedKindVocabularies(
      repo,
      contributor.kind.apiValue,
      contributor.vocabularies,
    );
  }
}

/// Returns the number of built-in values that every kind-owned vocabulary
/// must contain after seeding. Empty definitions are intentionally omitted:
/// they are populated only from catalog data or user input.
Map<String, int> devSeedVocabularyMinimumCounts() {
  final result = <String, int>{};

  void add(Iterable<VocabularyDefinition<dynamic>> definitions) {
    for (final definition in definitions) {
      final count = definition.builtIns.length;
      if (count > 0) {
        result[definition.key] = count;
      }
    }
  }

  for (final contributor in collectarrKindPickListDefinitionContributors) {
    if (contributor is! VocabularyPickListDefinitionContributor) continue;
    add(contributor.vocabularies);
  }
  return result;
}

Future<void> _seedKindVocabularies(
  PickListRepository repo,
  String mediaKind,
  Iterable<VocabularyDefinition<dynamic>> definitions,
) async {
  for (final definition in definitions) {
    final builtIns = [
      for (final value in definition.builtIns) value.toString(),
    ];
    if (builtIns.isEmpty) {
      continue;
    }
    await repo.captureValues(
      definition.key,
      builtIns,
      mediaKind: mediaKind,
    );
  }
}
