import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

abstract final class BookVocabularyIds {
  static const publisher = VocabularyId<String>('book.publisher');
  static const format = VocabularyId<String>('book.format');
  static const binding = VocabularyId<String>('book.binding');
  static const language = VocabularyId<String>('book.language');
  static const condition = VocabularyId<String>('book.condition');
}

abstract final class BookVocabularies {
  static const publisher = VocabularyDefinition<String>(
    id: BookVocabularyIds.publisher,
    label: 'Publisher',
    valuesFrom: TypedVocabularyProjector<BookCatalogMetadata>(
      _publisherCatalogValues,
    ),
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
    valuesFrom: TypedVocabularyProjector<BookCatalogMetadata>(
      _formatCatalogValues,
    ),
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
    valuesFrom: TypedVocabularyProjector<BookCatalogMetadata>(
      _languageCatalogValues,
    ),
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
    id: BookVocabularyIds.condition,
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

Iterable<String?> _publisherCatalogValues(BookCatalogMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.publisher,
    metadata.originalPublisher,
  ]);
}

Iterable<String?> _formatCatalogValues(BookCatalogMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
  ]);
}

Iterable<String?> _languageCatalogValues(BookCatalogMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.language,
    metadata.originalLanguage,
  ]);
}
