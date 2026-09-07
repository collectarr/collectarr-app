import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';

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
  static Future<int> countOwnedValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  ) {
    return countPickListOwnedValues(
      items: ComicOwnedRepository(db).listActive(),
      normalizedValue: normalizedValue,
      valuesFrom: (item) => _ownedValues(item, semanticName),
    );
  }

  static Iterable<String?> _ownedValues(
    ComicOwnedItem item,
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
      yield* pickListTextValues(item.details.toJson()[key]);
    }
  }

  static const publisher = VocabularyDefinition<String>(
    id: ComicVocabularyIds.publisher,
    label: 'Publisher',
    valuesFrom: TypedVocabularyProjector<ComicMedia>(_publisherCatalogValues),
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
    valuesFrom: TypedVocabularyProjector<ComicMedia>(_imprintCatalogValues),
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
    valuesFrom: TypedVocabularyProjector<ComicMedia>(
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
    valuesFrom: TypedVocabularyProjector<ComicMedia>(
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
    valuesFrom: TypedVocabularyProjector<ComicMedia>(_storyArcCatalogValues),
  );

  static const crossover = VocabularyDefinition<String>(
    id: ComicVocabularyIds.crossover,
    label: 'Crossover',
    multiValue: true,
    valuesFrom: TypedVocabularyProjector<ComicMedia>(_crossoverCatalogValues),
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

Iterable<String?> _publisherCatalogValues(ComicMedia metadata) sync* {
  yield* vocabularyValues([
    metadata.publisher,
    metadata.publishing?.originalPublisher,
  ]);
}

Iterable<String?> _imprintCatalogValues(ComicMedia metadata) {
  return vocabularyValues([metadata.imprint, metadata.publishing?.imprint]);
}

Iterable<String?> _seriesGroupCatalogValues(ComicMedia metadata) {
  return vocabularyValues([metadata.publishing?.seriesGroup]);
}

Iterable<String?> _physicalFormatCatalogValues(
  ComicMedia metadata,
) sync* {
  yield* vocabularyValues([
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
  ]);
}

Iterable<String?> _storyArcCatalogValues(ComicMedia metadata) {
  return vocabularyValues([metadata.storyArcs]);
}

Iterable<String?> _crossoverCatalogValues(ComicMedia metadata) {
  return vocabularyValues([metadata.crossover]);
}
