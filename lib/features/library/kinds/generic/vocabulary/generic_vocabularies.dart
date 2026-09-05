import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

abstract final class GenericVocabularyIds {
  static const condition = VocabularyId<String>('generic.condition');
  static const grade = VocabularyId<String>('generic.grade');
}

abstract final class GenericVocabularies {
  static const condition = VocabularyDefinition<String>(
    id: GenericVocabularyIds.condition,
    label: 'Condition',
    builtIns: [
      'Mint',
      'Near Mint',
      'Very Good',
      'Good',
      'Fair',
      'Poor',
    ],
  );

  static const grade = VocabularyDefinition<String>(
    id: GenericVocabularyIds.grade,
    label: 'Grade',
    builtIns: ['Ungraded'],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    condition,
    grade,
  ];
}
