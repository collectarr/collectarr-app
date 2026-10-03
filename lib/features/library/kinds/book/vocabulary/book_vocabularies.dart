import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_entry_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';

abstract final class BookVocabularyIds {
  static const publisher = VocabularyId<String>('book.publisher');
  static const format = VocabularyId<String>('book.format');
  static const binding = VocabularyId<String>('book.binding');
  static const language = VocabularyId<String>('book.language');
  static const condition = VocabularyId<String>('book.condition');
}

abstract final class BookVocabularies {
  static Future<int> countEntryValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  ) {
    return countPickListEntryValues(
      items: BookEntryRepository(db).listActive(),
      normalizedValue: normalizedValue,
      valuesFrom: (item) => _entryValues(item, semanticName),
    );
  }

  static Future<PickListEntryMergeResult> previewEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  ) {
    return previewPickListEntryMerge(
      items: BookEntryRepository(db).listActive(),
      idFrom: (item) => item.id.value,
      valuesFrom: (item) => _entryValues(item, semanticName),
      normalizedSourceValues: normalizedSourceValues,
    );
  }

  static Future<void> applyEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    return applyPickListEntryMerge(
      items: BookEntryRepository(db).listActive(),
      valuesFrom: (item) => _entryValues(item, semanticName),
      replaceValue: (item, sources, target) =>
          _replaceEntryValue(item, semanticName, sources, target),
      save: BookEntryRepository(db).upsert,
      normalizedSourceValues: normalizedSourceValues,
      targetValue: targetValue,
    );
  }

  static BookLibraryEntry _replaceEntryValue(
    BookLibraryEntry item,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    switch (semanticName) {
      case 'condition':
        return item.copyWith(condition: targetValue);
      case 'grade':
        return item.copyWith(grade: targetValue);
      case 'purchase_store':
        return item.copyWith(purchaseStore: targetValue);
      case 'sold_to':
        return item.copyWith(soldTo: targetValue);
      case 'collection_status':
        return item.copyWith(collectionStatus: targetValue);
      case 'tags':
        return item.copyWith(
          tags: replacePickListDelimitedValue(
            item.tags,
            normalizedSourceValues,
            targetValue,
          ),
        );
      case 'signed_by':
        return item.copyWith(
          details: item.details.copyWith(signedBy: targetValue),
        );
    }
    return item;
  }

  static Iterable<String?> _entryValues(
    BookLibraryEntry item,
    String semanticName,
  ) sync* {
    final standard = switch (semanticName) {
      'condition' => item.condition,
      'grade' => item.grade,
      'purchase_store' => item.purchaseStore,
      'sold_to' => item.soldTo,
      'collection_status' => item.collectionStatus,
      _ => null,
    };
    if (standard != null) {
      yield standard;
      return;
    }
    if (semanticName == 'tags') {
      yield* item.tags?.split(',') ?? const <String>[];
      return;
    }
    if (semanticName == 'signed_by') {
      yield item.details.signedBy;
    }
  }

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
