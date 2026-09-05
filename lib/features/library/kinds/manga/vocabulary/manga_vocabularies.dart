import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

abstract final class MangaVocabularyIds {
  static const publisher = VocabularyId<String>('manga.publisher');
  static const imprint = VocabularyId<String>('manga.imprint');
  static const demographic = VocabularyId<String>('manga.demographic');
  static const serialization = VocabularyId<String>('manga.serialization');
  static const format = VocabularyId<String>('manga.format');
}

abstract final class MangaVocabularies {
  static const publisher = VocabularyDefinition<String>(
    id: MangaVocabularyIds.publisher,
    label: 'Publisher',
    valuesFrom:
        TypedVocabularyProjector<MangaMetadata>(_publisherCatalogValues),
    builtIns: [
      'VIZ Media',
      'Kodansha USA',
      'Yen Press',
      'Seven Seas Entertainment',
      'Dark Horse Manga',
      'Square Enix Manga',
      'Shueisha',
      'Shogakukan',
      'Kadokawa',
      'Hakusensha',
    ],
  );

  static const imprint = VocabularyDefinition<String>(
    id: MangaVocabularyIds.imprint,
    label: 'Imprint',
    valuesFrom: TypedVocabularyProjector<MangaMetadata>(_imprintCatalogValues),
    builtIns: [
      'Shonen Jump',
      'Shojo Beat',
      'VIZ Signature',
      'Yen On',
      'Ghost Ship',
      'Steamship',
    ],
  );

  static const demographic = VocabularyDefinition<String>(
    id: MangaVocabularyIds.demographic,
    label: 'Demographic',
    builtIns: [
      'Shounen',
      'Seinen',
      'Shoujo',
      'Josei',
      'Kids',
    ],
  );

  static const serialization = VocabularyDefinition<String>(
    id: MangaVocabularyIds.serialization,
    label: 'Serialization Magazine',
    builtIns: [
      'Weekly Shonen Jump',
      'Weekly Shonen Magazine',
      'Weekly Young Jump',
      'Young Magazine',
      'Monthly Shonen Gangan',
      'Bessatsu Shonen Magazine',
      'LaLa',
      'Sho-Comi',
      'Manga Time Kirara',
      'Shonen Jump+',
    ],
  );

  static const format = VocabularyDefinition<String>(
    id: MangaVocabularyIds.format,
    label: 'Format',
    valuesFrom: TypedVocabularyProjector<MangaMetadata>(_formatCatalogValues),
    builtIns: [
      'Tankobon (Standard)',
      'Omnibus (2-in-1 / 3-in-1)',
      'Kanzenban (Complete Edition)',
      'Aizoban (Collector Edition)',
      'Bunkoban (Paperback)',
      'Digital',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    publisher,
    imprint,
    demographic,
    serialization,
    format,
  ];
}

Iterable<String?> _publisherCatalogValues(MangaMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.publisher,
    metadata.originalPublisher,
    metadata.localizedPublisher,
  ]);
}

Iterable<String?> _imprintCatalogValues(MangaMetadata metadata) {
  return vocabularyValues([metadata.imprint]);
}

Iterable<String?> _formatCatalogValues(MangaMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.editionFormat.label,
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
  ]);
}
