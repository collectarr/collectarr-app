import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';

abstract final class ComicVocabularyIds {
  static const publisher = VocabularyId<String>('comic.publisher');
  static const imprint = VocabularyId<String>('comic.imprint');
  static const seriesGroup = VocabularyId<String>('comic.series_group');
  static const physicalFormat = VocabularyId<String>('comic.physical_format');
  static const condition = VocabularyId<String>('comic.condition');
  static const grade = VocabularyId<String>('comic.grade');
  static const pageQuality = VocabularyId<String>('comic.page_quality');
  static const keyCategory = VocabularyId<String>('comic.key_category');
  static const storyArc = VocabularyId<String>('comic.story_arc');
  static const crossover = VocabularyId<String>('comic.crossover');
}

abstract final class ComicVocabularies {
  static Future<int> countEntryValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  ) {
    return countPickListEntryValues(
      items: ComicEntryRepository(db).listActive(),
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
      items: ComicEntryRepository(db).listActive(),
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
      items: ComicEntryRepository(db).listActive(),
      valuesFrom: (item) => _entryValues(item, semanticName),
      replaceValue: (item, sources, target) =>
          _replaceEntryValue(item, semanticName, sources, target),
      save: ComicEntryRepository(db).upsert,
      normalizedSourceValues: normalizedSourceValues,
      targetValue: targetValue,
    );
  }

  static ComicLibraryEntry _replaceEntryValue(
    ComicLibraryEntry item,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    switch (semanticName) {
      case 'condition':
        return item.copyWith(
            personal: item.personal.copyWith(condition: targetValue));
      case 'grade':
        return item.copyWith(
            personal: item.personal.copyWith(grade: targetValue));
      case 'purchase_store':
        return item.copyWith(
            personal: item.personal.copyWith(purchaseStore: targetValue));
      case 'sold_to':
        return item.copyWith(
            personal: item.personal.copyWith(soldTo: targetValue));
      case 'collection_status':
        return item.copyWith(
            personal: item.personal.copyWith(collectionStatus: targetValue));
      case 'tags':
        return item.copyWith(
            personal: item.personal.copyWith(
          tags: replacePickListDelimitedValue(
            item.personal.tags,
            normalizedSourceValues,
            targetValue,
          ),
        ));
    }
    final key = _entryDetailsKey(semanticName);
    if (key == null) return item;
    final details = item.personal.details.toJson()..[key] = targetValue;
    return item.copyWith(
        personal: item.personal
            .copyWith(details: ComicEntryDetails.fromJson(details)));
  }

  static String? _entryDetailsKey(String semanticName) =>
      switch (semanticName) {
        'raw_or_slabbed' => 'raw_or_slabbed',
        'grading_company' => 'grading_company',
        'grader_notes' => 'grader_notes',
        'signed_by' => 'signed_by',
        'label_type' => 'label_type',
        'custom_label' => 'custom_label',
        'page_quality' => 'page_quality',
        'certification_number' => 'certification_number',
        'key_category' => 'key_category',
        'key_severity' => 'key_severity',
        _ => null,
      };

  static Iterable<String?> _entryValues(
    ComicLibraryEntry item,
    String semanticName,
  ) sync* {
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
      yield* item.personal.tags?.split(',') ?? const <String>[];
      return;
    }
    final key = switch (semanticName) {
      'raw_or_slabbed' => 'raw_or_slabbed',
      'grading_company' => 'grading_company',
      'grader_notes' => 'grader_notes',
      'signed_by' => 'signed_by',
      'label_type' => 'label_type',
      'custom_label' => 'custom_label',
      'page_quality' => 'page_quality',
      'certification_number' => 'certification_number',
      'key_category' => 'key_category',
      'key_severity' => 'key_severity',
      _ => null,
    };
    if (key != null) {
      yield* pickListTextValues(item.personal.details.toJson()[key]);
    }
  }

  static const publisher = VocabularyDefinition<String>(
    id: ComicVocabularyIds.publisher,
    label: 'Publisher',
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_publisherCatalogValues),
    builtIns: [
      'Marvel Comics',
      'DC Comics',
      'Image Comics',
      'Dark Horse Comics',
      'IDW Publishing',
      'Boom! Studios',
      'Dynamite Entertainment',
      'Valiant Comics',
    ],
  );

  static const imprint = VocabularyDefinition<String>(
    id: ComicVocabularyIds.imprint,
    label: 'Imprint',
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_imprintCatalogValues),
    builtIns: [
      'Vertigo',
      'Black Label',
      'Max',
      'Icon',
      'Wildstorm',
      'Epic Comics',
      'Milestone',
    ],
  );

  static const seriesGroup = VocabularyDefinition<String>(
    id: ComicVocabularyIds.seriesGroup,
    label: 'Series Group',
    valuesFrom: TypedVocabularyProjector<ComicCatalogItem>(
      _seriesGroupCatalogValues,
    ),
    builtIns: [
      'Spider-Man',
      'Batman',
      'X-Men',
      'Avengers',
      'Superman',
      'Justice League',
      'Star Wars',
    ],
  );

  static const physicalFormat = VocabularyDefinition<String>(
    id: ComicVocabularyIds.physicalFormat,
    label: 'Format',
    valuesFrom: TypedVocabularyProjector<ComicCatalogItem>(
      _physicalFormatCatalogValues,
    ),
    builtIns: [
      'Single Issue',
      'Trade Paperback',
      'Hardcover',
      'Omnibus',
      'Compendium',
      'Deluxe Edition',
      'Graphic Novel',
      'Ashcan',
      'Prestige Format',
    ],
  );

  static const condition = VocabularyDefinition<String>(
    id: ComicVocabularyIds.condition,
    label: 'Condition',
    builtIns: [
      'Mint',
      'Near Mint',
      'Very Fine',
      'Fine',
      'Very Good',
      'Good',
      'Fair',
      'Poor',
    ],
  );

  static const grade = VocabularyDefinition<String>(
    id: ComicVocabularyIds.grade,
    label: 'Grade',
    builtIns: [
      'Ungraded',
      '10.0 Gem Mint',
      '9.9 Mint',
      '9.8 Near Mint/Mint',
      '9.6 Near Mint+',
      '9.4 Near Mint',
      '9.2 Near Mint-',
      '9.0 Very Fine/Near Mint',
      '8.5 Very Fine+',
      '8.0 Very Fine',
      '7.5 Very Fine-',
      '7.0 Fine/Very Fine',
      '6.5 Fine+',
      '6.0 Fine',
      '5.5 Fine-',
      '5.0 Very Good/Fine',
      '4.5 Very Good+',
      '4.0 Very Good',
      '3.5 Very Good-',
      '3.0 Good/Very Good',
      '2.5 Good+',
      '2.0 Good',
      '1.8 Good-',
      '1.5 Fair/Good',
      '1.0 Fair',
      '0.5 Poor',
    ],
  );

  static const pageQuality = VocabularyDefinition<String>(
    id: ComicVocabularyIds.pageQuality,
    label: 'Page Quality',
    builtIns: [
      'White',
      'Off-White to White',
      'Off-White',
      'Cream to Off-White',
      'Cream',
      'Tan',
      'Dark Tan',
      'Brittle',
    ],
  );

  static const keyCategory = VocabularyDefinition<String>(
    id: ComicVocabularyIds.keyCategory,
    label: 'Key Category',
    builtIns: [
      '1st appearance',
      '1st full appearance',
      '1st cameo appearance',
      'Origin',
      'Death',
      'Iconic cover',
      'Classic cover',
      'Key storyline',
      'Major crossover/event',
      '1st team appearance',
    ],
  );

  static const storyArc = VocabularyDefinition<String>(
    id: ComicVocabularyIds.storyArc,
    label: 'Story Arc',
    multiValue: true,
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_storyArcCatalogValues),
  );

  static const crossover = VocabularyDefinition<String>(
    id: ComicVocabularyIds.crossover,
    label: 'Crossover',
    multiValue: true,
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_crossoverCatalogValues),
  );

  static const all = <VocabularyDefinition<dynamic>>[
    publisher,
    imprint,
    seriesGroup,
    physicalFormat,
    condition,
    grade,
    pageQuality,
    keyCategory,
    storyArc,
    crossover,
  ];
}

Iterable<String?> _publisherCatalogValues(ComicCatalogItem metadata) sync* {
  yield* vocabularyValues([
    metadata.publisher,
    metadata.publishing?.originalPublisher,
  ]);
}

Iterable<String?> _imprintCatalogValues(ComicCatalogItem metadata) {
  return vocabularyValues([metadata.imprint, metadata.publishing?.imprint]);
}

Iterable<String?> _seriesGroupCatalogValues(ComicCatalogItem metadata) {
  return vocabularyValues([metadata.publishing?.seriesGroup]);
}

Iterable<String?> _physicalFormatCatalogValues(
  ComicCatalogItem metadata,
) sync* {
  yield* vocabularyValues([
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
  ]);
}

Iterable<String?> _storyArcCatalogValues(ComicCatalogItem metadata) {
  return vocabularyValues([metadata.storyArcs]);
}

Iterable<String?> _crossoverCatalogValues(ComicCatalogItem metadata) {
  return vocabularyValues([metadata.crossover]);
}
