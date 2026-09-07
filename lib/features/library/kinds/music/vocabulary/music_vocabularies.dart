import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';

abstract final class MusicVocabularyIds {
  static const condition = VocabularyId<String>('music.condition');
  static const format = VocabularyId<String>('music.format');
  static const packaging = VocabularyId<String>('music.packaging');
  static const recordLabel = VocabularyId<String>('music.record_label');
  static const genre = VocabularyId<String>('music.genre');
  static const mediaType = VocabularyId<String>('music.media_type');
  static const creditRole = VocabularyId<String>('music.credit_role');
  static const country = VocabularyId<String>('music.country');
}

abstract final class MusicVocabularies {
  static Future<int> countOwnedValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  ) {
    return countPickListOwnedValues(
      items: MusicOwnedRepository(db).listActive(),
      normalizedValue: normalizedValue,
      valuesFrom: (item) => _ownedValues(item, semanticName),
    );
  }

  static Iterable<String?> _ownedValues(
    MusicOwnedItem item,
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

  static const condition = VocabularyDefinition<String>(
    id: MusicVocabularyIds.condition,
    label: 'Condition',
    builtIns: [
      'Mint',
      'Near Mint',
      'Excellent',
      'Very Good',
      'Good',
      'Fair',
      'Poor',
    ],
  );

  static const format = VocabularyDefinition<String>(
    id: MusicVocabularyIds.format,
    label: 'Format',
    valuesFrom:
        TypedVocabularyProjector<MusicCatalogMetadata>(_formatCatalogValues),
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
    valuesFrom: TypedVocabularyProjector<MusicCatalogMetadata>(
      _packagingCatalogValues,
    ),
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
    valuesFrom: TypedVocabularyProjector<MusicCatalogMetadata>(
      _recordLabelCatalogValues,
    ),
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

  static const genre = VocabularyDefinition<String>(
    id: MusicVocabularyIds.genre,
    label: 'Genre',
    valuesFrom: TypedVocabularyProjector<MusicCatalogMetadata>(_genreValues),
    builtIns: [
      'Rock',
      'Pop',
      'Jazz',
      'Classical',
      'Electronic',
      'Hip-Hop',
      'Metal',
      'Blues',
      'Folk',
      'Soundtrack',
    ],
  );

  static const mediaType = VocabularyDefinition<String>(
    id: MusicVocabularyIds.mediaType,
    label: 'Media Type',
    valuesFrom:
        TypedVocabularyProjector<MusicCatalogMetadata>(_mediaTypeValues),
    builtIns: [
      'Vinyl',
      'CD',
      'Cassette',
      'SACD',
      'Digital',
    ],
  );

  static const creditRole = VocabularyDefinition<String>(
    id: MusicVocabularyIds.creditRole,
    label: 'Credit Role',
    valuesFrom:
        TypedVocabularyProjector<MusicCatalogMetadata>(_creditRoleValues),
    builtIns: [
      'Artist',
      'Performer',
      'Musician',
      'Composer',
      'Conductor',
      'Producer',
      'Engineer',
      'Remixer',
    ],
  );

  static const country = VocabularyDefinition<String>(
    id: MusicVocabularyIds.country,
    label: 'Country',
    valuesFrom: TypedVocabularyProjector<MusicCatalogMetadata>(_countryValues),
    builtIns: [
      'US',
      'GB',
      'DE',
      'FR',
      'JP',
      'CA',
      'AU',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    condition,
    format,
    packaging,
    recordLabel,
    genre,
    mediaType,
    creditRole,
    country,
  ];
}

Iterable<String?> _formatCatalogValues(MusicCatalogMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
    metadata.releases.map((release) => release.format),
  ]);
}

Iterable<String?> _packagingCatalogValues(MusicCatalogMetadata metadata) {
  return vocabularyValues([metadata.packaging]);
}

Iterable<String?> _recordLabelCatalogValues(MusicCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.recordLabel,
    metadata.publisher,
    metadata.releases.map((release) => release.label),
  ]);
}

Iterable<String?> _genreValues(MusicCatalogMetadata metadata) {
  return vocabularyValues([metadata.genres]);
}

Iterable<String?> _mediaTypeValues(MusicCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
    metadata.releases.map((release) => release.format),
  ]);
}

Iterable<String?> _creditRoleValues(MusicCatalogMetadata metadata) {
  return vocabularyValues(metadata.credits.map((credit) => credit.role));
}

Iterable<String?> _countryValues(MusicCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.country,
    metadata.releases.map((release) => release.country),
  ]);
}
