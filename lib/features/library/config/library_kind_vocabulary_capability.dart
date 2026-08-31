import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';

abstract class LibraryKindVocabularyCapability {
  const LibraryKindVocabularyCapability();

  Iterable<VocabularyDefinition<dynamic>> get definitions;

  VocabularyDefinition<T>? definitionFor<T>(VocabularyId<T> id) {
    for (final def in definitions) {
      if (def.id.value == id.value) {
        return def as VocabularyDefinition<T>;
      }
    }
    return null;
  }
}

class StandardKindVocabularyCapability extends LibraryKindVocabularyCapability {
  const StandardKindVocabularyCapability(this._definitions);

  final List<VocabularyDefinition<dynamic>> _definitions;

  @override
  Iterable<VocabularyDefinition<dynamic>> get definitions => _definitions;
}
