import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';

abstract final class BookVocabularyIds {
  static const publisher = VocabularyId<String>('book.publisher');
  static const format = VocabularyId<String>('book.format');
  static const binding = VocabularyId<String>('book.binding');
  static const language = VocabularyId<String>('book.language');
}

abstract final class BookVocabularies {
  static const publisher = VocabularyDefinition<String>(
    id: BookVocabularyIds.publisher,
    label: 'Publisher',
    catalogValueReader: _publisherCatalogValues,
    builtIns: [
      'Penguin Random House',
      'HarperCollins',
      'Simon & Schuster',
      'Hachette Book Group',
      'Macmillan Publishers',
      'Tor Books',
      'Orbit Books',
      'Del Rey',
      'Vintage Books',
      'Anchor Books',
      'Oxford University Press',
    ],
  );

  static const format = VocabularyDefinition<String>(
    id: BookVocabularyIds.format,
    label: 'Format',
    catalogValueReader: _formatCatalogValues,
    builtIns: [
      'Hardcover',
      'Trade Paperback',
      'Mass Market Paperback',
      'Leather Bound',
      'Box Set',
      'E-Book',
      'Audiobook',
    ],
  );

  static const binding = VocabularyDefinition<String>(
    id: BookVocabularyIds.binding,
    label: 'Binding / Edition Type',
    builtIns: [
      'Standard',
      'First Edition',
      'First Printing',
      'Signed Edition',
      'Limited Edition',
      'Numbered Edition',
      'Illustrated Edition',
      'Special Anniversary Edition',
      'Book Club Edition',
    ],
  );

  static const language = VocabularyDefinition<String>(
    id: BookVocabularyIds.language,
    label: 'Language',
    catalogValueReader: _languageCatalogValues,
    builtIns: [
      'English',
      'Spanish',
      'French',
      'German',
      'Japanese',
      'Italian',
      'Romanian',
      'Russian',
      'Chinese',
    ],
  );

  static const condition = VocabularyDefinition<String>(
    id: VocabularyId<String>('book.condition'),
    label: 'Condition',
    builtIns: [
      'New',
      'Like New',
      'Very Good',
      'Good',
      'Acceptable',
      'Poor',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    publisher,
    format,
    binding,
    language,
    condition,
  ];
}

Iterable<String?> _publisherCatalogValues(Map<String, dynamic> payload) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'publisher');
  yield* vocabularyNestedPayloadValuesForKey(
    payload,
    'publishing',
    'original_publisher',
  );
}

Iterable<String?> _formatCatalogValues(Map<String, dynamic> payload) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'format');
  yield* vocabularyPayloadValuesForKey(payload, 'physical_format_label');
  yield* vocabularyPayloadValuesForKey(payload, 'physical_format');
}

Iterable<String?> _languageCatalogValues(Map<String, dynamic> payload) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'language');
  yield* vocabularyNestedPayloadValuesForKey(
    payload,
    'publishing',
    'original_language',
  );
}
