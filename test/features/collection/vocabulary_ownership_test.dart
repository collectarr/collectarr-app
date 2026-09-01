import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_repository.dart';
import 'package:collectarr_app/features/library/config/library_kind_vocabulary_capability.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PR 1: Vocabulary Ownership Model', () {
    late LocalDatabase db;
    late DatabaseVocabularyRepository repo;

    setUp(() {
      db = LocalDatabase(NativeDatabase.memory());
      repo = DatabaseVocabularyRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('VocabularyId and VocabularyDefinition model integrity', () {
      const publisherId = VocabularyId<String>('comic.publisher');
      const publisherDef = VocabularyDefinition<String>(
        id: publisherId,
        label: 'Publisher',
        builtIns: ['Marvel Comics', 'DC Comics', 'Image Comics'],
        allowCustomValues: true,
        multiValue: false,
      );

      expect(publisherDef.key, 'comic.publisher');
      expect(publisherDef.builtIns, contains('Marvel Comics'));
      expect(publisherDef.allowCustomValues, isTrue);
    });

    test(
        'DatabaseVocabularyRepository loads and merges built-ins, custom values, and selected values',
        () async {
      const gradeId = VocabularyId<String>('comic.grade');
      const gradeDef = VocabularyDefinition<String>(
        id: gradeId,
        label: 'Grade',
        builtIns: ['9.8', '9.6', '9.4', '9.2', '9.0'],
        allowCustomValues: true,
      );

      // Save custom user grade
      await repo.saveCustomValue(
        mediaKind: 'comic',
        definition: gradeDef,
        value: '9.9 (Mint+)',
      );

      final options = await repo.loadOptions(
        mediaKind: 'comic',
        definition: gradeDef,
        selectedValues: ['Ungraded'],
      );

      expect(options, contains('9.8'));
      expect(options, contains('9.9 (Mint+)'));
      expect(options, contains('Ungraded'));
    });

    test(
        'LibraryKindVocabularyCapability provides typed lookup for definitions',
        () {
      const publisherId = VocabularyId<String>('comic.publisher');
      const pageQualityId = VocabularyId<String>('comic.page_quality');

      final capability = StandardKindVocabularyCapability([
        const VocabularyDefinition<String>(
          id: publisherId,
          label: 'Publisher',
          builtIns: ['Marvel', 'DC'],
        ),
        const VocabularyDefinition<String>(
          id: pageQualityId,
          label: 'Page Quality',
          builtIns: ['White', 'Off-White to White', 'Cream to Off-White'],
        ),
      ]);

      final foundPublisher = capability.definitionFor(publisherId);
      expect(foundPublisher, isNotNull);
      expect(foundPublisher!.builtIns, contains('Marvel'));

      final foundQuality = capability.definitionFor(pageQualityId);
      expect(foundQuality, isNotNull);
      expect(foundQuality!.builtIns, contains('White'));

      const unknownId = VocabularyId<String>('unknown.voc');
      expect(capability.definitionFor(unknownId), isNull);
    });
  });
}
