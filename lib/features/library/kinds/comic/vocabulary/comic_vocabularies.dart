import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_field_identities.dart';

abstract final class ComicVocabularyIds {
  static const gradingCompany = VocabularyId<String>('comic.grading_company');
  static const labelType = VocabularyId<String>('comic.label_type');
  static const customLabel = VocabularyId<String>('comic.custom_label');
  static const publicationAge = VocabularyId<String>('comic.publication_age');
  static const publisher = VocabularyId<String>('comic.publisher');
  static const imprint = ComicFieldIdentities.imprintVocabulary;
  static const seriesGroup = VocabularyId<String>('comic.series_group');
  static const physicalFormat = VocabularyId<String>('comic.physical_format');
  static const condition = VocabularyId<String>('comic.condition');
  static const grade = VocabularyId<String>('comic.grade');
  static const pageQuality = VocabularyId<String>('comic.page_quality');
  static const keyCategory = VocabularyId<String>('comic.key_category');
  static const storyArc = VocabularyId<String>('comic.story_arc');
  static const crossover = VocabularyId<String>('comic.crossover');
  static const country = VocabularyId<String>('comic.country');
  static const language = VocabularyId<String>('comic.language');
}

abstract final class ComicVocabularies {
  static Future<List<String>> entryOptions(
      LocalDatabase db, String semanticName) async {
    return [
      for (final item in await ComicEntryRepository(db).listActive())
        ..._entryValues(item, semanticName)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
    ];
  }

  static Future<Map<String, int>> entryUsageCounts(
          LocalDatabase db, String semanticName) =>
      countPickListEntryUsages(
          items: ComicEntryRepository(db).listActive(),
          valuesFrom: (item) => _entryValues(item, semanticName));

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
          tags: replacePickListValueInList(
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
      yield* item.personal.tags;
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
    for (final vocabulary in all) {
      if (vocabulary.key.split('.').last == semanticName) {
        yield* vocabulary.valuesFrom?.call(item.metadata) ?? const <String>[];
      }
    }
  }

  static const publisher = VocabularyDefinition<String>(
    id: ComicVocabularyIds.publisher,
    label: 'Publisher',
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_publisherCatalogValues),
  );

  static const imprint = VocabularyDefinition<String>(
    id: ComicVocabularyIds.imprint,
    label: 'Imprint',
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_imprintCatalogValues),
  );

  static const seriesGroup = VocabularyDefinition<String>(
    id: ComicVocabularyIds.seriesGroup,
    label: 'Series Group',
    valuesFrom: TypedVocabularyProjector<ComicCatalogItem>(
      _seriesGroupCatalogValues,
    ),
  );

  static const physicalFormat = VocabularyDefinition<String>(
    id: ComicVocabularyIds.physicalFormat,
    label: 'Format',
    valuesFrom: TypedVocabularyProjector<ComicCatalogItem>(
      _physicalFormatCatalogValues,
    ),
  );

  static const condition = VocabularyDefinition<String>(
    id: ComicVocabularyIds.condition,
    label: 'Condition',
  );

  static const grade = VocabularyDefinition<String>(
    id: ComicVocabularyIds.grade,
    label: 'Grade',
  );

  static const pageQuality = VocabularyDefinition<String>(
    id: ComicVocabularyIds.pageQuality,
    label: 'Page Quality',
  );

  static const keyCategory = VocabularyDefinition<String>(
    id: ComicVocabularyIds.keyCategory,
    label: 'Key Category',
  );

  static const storyArc = VocabularyDefinition<String>(
    id: ComicVocabularyIds.storyArc,
    label: 'Story Arc',
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_storyArcCatalogValues),
  );

  static const crossover = VocabularyDefinition<String>(
    id: ComicVocabularyIds.crossover,
    label: 'Crossover',
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_crossoverCatalogValues),
  );

  static const country = VocabularyDefinition<String>(
    id: ComicVocabularyIds.country,
    label: 'Country',
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_countryCatalogValues),
  );

  static const language = VocabularyDefinition<String>(
    id: ComicVocabularyIds.language,
    label: 'Language',
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_languageCatalogValues),
  );

  static const publicationAge = VocabularyDefinition<String>(
    id: ComicVocabularyIds.publicationAge,
    label: 'Age',
    valuesFrom:
        TypedVocabularyProjector<ComicCatalogItem>(_publicationAgeValues),
  );

  static const gradingCompany = VocabularyDefinition<String>(
      id: ComicVocabularyIds.gradingCompany, label: 'Grading Company');
  static const labelType = VocabularyDefinition<String>(
      id: ComicVocabularyIds.labelType, label: 'Label Type');
  static const customLabel = VocabularyDefinition<String>(
      id: ComicVocabularyIds.customLabel, label: 'Custom Label');

  static const all = <VocabularyDefinition<dynamic>>[
    gradingCompany,
    labelType,
    customLabel,
    publicationAge,
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
    country,
    language,
  ];
}

Iterable<String?> _publisherCatalogValues(ComicCatalogItem metadata) sync* {
  yield* vocabularyValues([metadata.publisher]);
}

Iterable<String?> _imprintCatalogValues(ComicCatalogItem metadata) {
  return vocabularyValues([metadata.imprint]);
}

Iterable<String?> _seriesGroupCatalogValues(ComicCatalogItem metadata) {
  return vocabularyValues([metadata.seriesGroup]);
}

Iterable<String?> _physicalFormatCatalogValues(
  ComicCatalogItem metadata,
) sync* {
  yield* vocabularyValues([
    metadata.physicalFormat,
  ]);
}

Iterable<String?> _storyArcCatalogValues(ComicCatalogItem metadata) {
  return vocabularyValues(
    metadata.storyArcs.map((arc) => arc.name).whereType<String>(),
  );
}

Iterable<String?> _crossoverCatalogValues(ComicCatalogItem metadata) {
  return vocabularyValues([metadata.crossover]);
}

Iterable<String?> _countryCatalogValues(ComicCatalogItem metadata) =>
    vocabularyValues([metadata.country]);

Iterable<String?> _languageCatalogValues(ComicCatalogItem metadata) =>
    vocabularyValues([metadata.language]);

Iterable<String?> _publicationAgeValues(ComicCatalogItem metadata) =>
    vocabularyValues([metadata.publicationAge]);
