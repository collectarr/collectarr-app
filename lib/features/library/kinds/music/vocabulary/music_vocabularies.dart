import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';

abstract final class MusicVocabularyIds {
  static const format = VocabularyId<String>('music.format');
  static const packaging = VocabularyId<String>('music.packaging');
  static const recordLabel = VocabularyId<String>('music.record_label');
}

abstract final class MusicVocabularies {
  static const format = VocabularyDefinition<String>(
    id: MusicVocabularyIds.format,
    label: 'Format',
    catalogValueReader: _formatCatalogValues,
    builtIns: [
      'Vinyl (12" LP)',
      'Vinyl (7" Single)',
      'Vinyl (10" EP)',
      'CD',
      'Cassette',
      'SACD',
      'FLAC / Hi-Res Digital',
      'Digital Download',
    ],
  );

  static const packaging = VocabularyDefinition<String>(
    id: MusicVocabularyIds.packaging,
    label: 'Packaging',
    catalogValueReader: _packagingCatalogValues,
    builtIns: [
      'Standard Jewel Case',
      'Digipak',
      'Gatefold Sleeve',
      'Box Set',
      'Deluxe Cardboard Sleeve',
      'Cardboard Slipcase',
    ],
  );

  static const recordLabel = VocabularyDefinition<String>(
    id: MusicVocabularyIds.recordLabel,
    label: 'Record Label',
    catalogValueReader: _recordLabelCatalogValues,
    builtIns: [
      'Columbia Records',
      'Atlantic Records',
      'Warner Records',
      'Interscope Records',
      'Def Jam Recordings',
      'Epic Records',
      'Sub Pop',
      '4AD',
      'Blue Note Records',
      'Deutsche Grammophon',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    format,
    packaging,
    recordLabel,
  ];
}

Iterable<String?> _formatCatalogValues(Map<String, dynamic> payload) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'format');
  yield* vocabularyPayloadValuesForKey(payload, 'physical_format_label');
  yield* vocabularyPayloadValuesForKey(payload, 'physical_format');
}

Iterable<String?> _packagingCatalogValues(Map<String, dynamic> payload) {
  return vocabularyNestedPayloadValuesForKey(payload, 'music', 'packaging');
}

Iterable<String?> _recordLabelCatalogValues(
    Map<String, dynamic> payload) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'record_label');
  yield* vocabularyPayloadValuesForKey(payload, 'publisher');
}
