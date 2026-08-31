import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';

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
  static const publisher = VocabularyDefinition<String>(
    id: ComicVocabularyIds.publisher,
    label: 'Publisher',
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
  );

  static const crossover = VocabularyDefinition<String>(
    id: ComicVocabularyIds.crossover,
    label: 'Crossover',
    multiValue: true,
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
