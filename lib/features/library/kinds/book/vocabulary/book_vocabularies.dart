import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_entry_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/config/field_identities.dart';

abstract final class BookVocabularyIds {
  static const publisher = BookFieldIdentities.publisherVocabulary;
  static const format = BookFieldIdentities.formatVocabulary;
  static const binding = VocabularyId<String>('book.binding');
  static const language = VocabularyId<String>('book.language');
  static const condition = VocabularyId<String>('book.condition');
  static const genre = VocabularyId<String>('book.genre');
  static const boxSet = VocabularyId<String>('book.box_set');
  static const publicationPlace =
      VocabularyId<String>('book.publication_place');
  static const printedBy = VocabularyId<String>('book.printed_by');
  static const paperType = VocabularyId<String>('book.paper_type');
  static const extras = VocabularyId<String>('book.extras');
  static const subject = VocabularyId<String>('book.subject');
  static const country = VocabularyId<String>('book.country');
}

abstract final class BookVocabularies {
  static Future<List<String>> entryOptions(
      LocalDatabase db, String semanticName) async {
    return [
      for (final item in await BookEntryRepository(db).listActive())
        ..._entryValues(item, semanticName)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
    ];
  }

  static Future<Map<String, int>> entryUsageCounts(
          LocalDatabase db, String semanticName) =>
      countPickListEntryUsages(
          items: BookEntryRepository(db).listActive(),
          valuesFrom: (item) => _entryValues(item, semanticName));

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
    String? replace(String? value) => value != null &&
            normalizedSourceValues.contains(normalizePickListValue(value))
        ? targetValue
        : value;
    switch (semanticName) {
      case 'genre':
        return item.copyWith(
            metadata: item.metadata.copyWith(
                genres: replacePickListValueInList(item.metadata.genres,
                    normalizedSourceValues, targetValue)));
      case 'subject':
        return item.copyWith(
            metadata: item.metadata.copyWith(
                subjects: replacePickListValueInList(item.metadata.subjects,
                    normalizedSourceValues, targetValue)));
      case 'publisher':
        return item.copyWith(
            metadata: item.metadata.copyWith(
                publisher: replace(item.metadata.publisher),
                originalPublisher: replace(item.metadata.originalPublisher)));
      case 'country':
        return item.copyWith(
            metadata: item.metadata.copyWith(
                country: replace(item.metadata.country),
                originalCountry: replace(item.metadata.originalCountry)));
      case 'language':
        return item.copyWith(
            metadata: item.metadata.copyWith(
                language: replace(item.metadata.language),
                originalLanguage: replace(item.metadata.originalLanguage)));
      case 'publication_place':
        return item.copyWith(
            metadata: item.metadata.copyWith(
                publicationPlace: replace(item.metadata.publicationPlace),
                originalPublicationPlace:
                    replace(item.metadata.originalPublicationPlace)));
      case 'box_set':
        return item.copyWith(
            metadata:
                item.metadata.copyWith(boxSet: replace(item.metadata.boxSet)));
      case 'printed_by':
        return item.copyWith(
            metadata: item.metadata
                .copyWith(printedBy: replace(item.metadata.printedBy)));
      case 'paper_type':
        return item.copyWith(
            metadata: item.metadata
                .copyWith(paperType: replace(item.metadata.paperType)));
      case 'extras':
        return item.copyWith(
            metadata: item.metadata.copyWith(
                extras: replacePickListValueInList(item.metadata.extras,
                    normalizedSourceValues, targetValue)));
      case 'binding':
        return item.copyWith(
            metadata: item.metadata
                .copyWith(binding: replace(item.metadata.binding)));
      case 'format':
        return item.copyWith(
            metadata: item.metadata.copyWith(
                physicalFormat: replace(item.metadata.physicalFormat)));
      case 'condition':
        return item.copyWith(
            personal: item.personal.copyWith(
                condition: replace(item.personal.condition),
                details: item.personal.details.copyWith(
                    dustJacketCondition:
                        replace(item.personal.details.dustJacketCondition))));
      case 'grade':
        return item.copyWith(
            personal: item.personal.copyWith(grade: targetValue));
      case 'purchase_store':
        return item.copyWith(
          personal: item.personal.copyWith(purchaseStore: targetValue),
        );
      case 'sold_to':
        return item.copyWith(
            personal: item.personal.copyWith(soldTo: targetValue));
      case 'collection_status':
        return item.copyWith(
          personal: item.personal.copyWith(collectionStatus: targetValue),
        );
      case 'tags':
        return item.copyWith(
          personal: item.personal.copyWith(
            tags: replacePickListValueInList(
              item.personal.tags,
              normalizedSourceValues,
              targetValue,
            ),
          ),
        );
      case 'signed_by':
        return item.copyWith(
          personal: item.personal.copyWith(
            details: item.personal.details.copyWith(signedBy: targetValue),
          ),
        );
    }
    return item;
  }

  static Iterable<String?> _entryValues(
    BookLibraryEntry item,
    String semanticName,
  ) sync* {
    if (semanticName == 'condition') {
      yield item.personal.condition;
      yield item.personal.details.dustJacketCondition;
      return;
    }
    if (semanticName == 'binding') {
      yield item.metadata.binding;
      return;
    }
    final standard = switch (semanticName) {
      'condition' => item.personal.condition,
      'grade' => item.personal.grade,
      'purchase_store' => item.personal.purchaseStore,
      'sold_to' => item.personal.soldTo,
      'collection_status' => item.personal.collectionStatus,
      _ => null,
    };
    if (standard != null) {
      yield standard;
      return;
    }
    if (semanticName == 'tags') {
      yield* item.personal.tags;
      return;
    }
    if (semanticName == 'signed_by') {
      yield item.personal.details.signedBy;
    }
    for (final vocabulary in all) {
      if (vocabulary.key.split('.').last == semanticName) {
        yield* vocabulary.valuesFrom?.call(item.metadata) ?? const <String>[];
      }
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

  static const genre = VocabularyDefinition<String>(
    id: BookVocabularyIds.genre,
    label: 'Genre',
    valuesFrom:
        TypedVocabularyProjector<BookCatalogMetadata>(_genreCatalogValues),
  );
  static const subject = VocabularyDefinition<String>(
    id: BookVocabularyIds.subject,
    label: 'Subject',
    valuesFrom:
        TypedVocabularyProjector<BookCatalogMetadata>(_subjectCatalogValues),
  );
  static const country = VocabularyDefinition<String>(
    id: BookVocabularyIds.country,
    label: 'Country',
    valuesFrom:
        TypedVocabularyProjector<BookCatalogMetadata>(_countryCatalogValues),
  );
  static const boxSet = VocabularyDefinition<String>(
      id: BookVocabularyIds.boxSet,
      label: 'Box Set',
      valuesFrom:
          TypedVocabularyProjector<BookCatalogMetadata>(_boxSetCatalogValues));
  static const publicationPlace = VocabularyDefinition<String>(
      id: BookVocabularyIds.publicationPlace,
      label: 'Publication Place',
      valuesFrom: TypedVocabularyProjector<BookCatalogMetadata>(
          _publicationPlaceCatalogValues));
  static const printedBy = VocabularyDefinition<String>(
      id: BookVocabularyIds.printedBy,
      label: 'Printed By',
      valuesFrom: TypedVocabularyProjector<BookCatalogMetadata>(
          _printedByCatalogValues));
  static const paperType = VocabularyDefinition<String>(
      id: BookVocabularyIds.paperType,
      label: 'Paper Type',
      valuesFrom: TypedVocabularyProjector<BookCatalogMetadata>(
          _paperTypeCatalogValues));
  static const extras = VocabularyDefinition<String>(
      id: BookVocabularyIds.extras,
      label: 'Extras',
      valuesFrom:
          TypedVocabularyProjector<BookCatalogMetadata>(_extrasCatalogValues));
  static const all = <VocabularyDefinition<dynamic>>[
    publisher,
    format,
    binding,
    language,
    condition,
    boxSet,
    publicationPlace,
    printedBy,
    paperType,
    extras,
    genre,
    subject,
    country,
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
    metadata.physicalFormat,
  ]);
}

Iterable<String?> _languageCatalogValues(BookCatalogMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.language,
    metadata.originalLanguage,
  ]);
}

Iterable<String?> _genreCatalogValues(BookCatalogMetadata metadata) =>
    metadata.genres;
Iterable<String?> _subjectCatalogValues(BookCatalogMetadata metadata) =>
    metadata.subjects;
Iterable<String?> _countryCatalogValues(BookCatalogMetadata metadata) =>
    [metadata.country, metadata.originalCountry];

Iterable<String?> _boxSetCatalogValues(BookCatalogMetadata metadata) =>
    [metadata.boxSet];

Iterable<String?> _publicationPlaceCatalogValues(
        BookCatalogMetadata metadata) =>
    [metadata.publicationPlace, metadata.originalPublicationPlace];

Iterable<String?> _printedByCatalogValues(BookCatalogMetadata metadata) =>
    [metadata.printedBy];

Iterable<String?> _paperTypeCatalogValues(BookCatalogMetadata metadata) =>
    [metadata.paperType];

Iterable<String?> _extrasCatalogValues(BookCatalogMetadata metadata) =>
    metadata.extras;
