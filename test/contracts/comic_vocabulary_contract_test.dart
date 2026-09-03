import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import 'vocabulary_contract.dart';

void main() {
  defineVocabularyContract<List<VocabularyDefinition<dynamic>>>(
    name: 'Comic',
    create: () => ComicVocabularies.all,
    vocabularies: (definitions) {
      expect(definitions, hasLength(10));

      final ids = definitions.map((definition) => definition.id.value).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(
        definitions.map((definition) => definition.label),
        everyElement(isNotEmpty),
      );

      return {
        for (final definition in definitions)
          definition.id.value:
              definition.builtIns.map((value) => value.toString()),
      };
    },
  );
}
