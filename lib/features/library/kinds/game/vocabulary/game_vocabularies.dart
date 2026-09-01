import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';

abstract final class GameVocabularyIds {
  static const platform = VocabularyId<String>('game.platform');
  static const region = VocabularyId<String>('game.region');
  static const edition = VocabularyId<String>('game.edition');
  static const ageRating = VocabularyId<String>('game.age_rating');
  static const condition = VocabularyId<String>('game.condition');
}

abstract final class GameVocabularies {
  static const platform = VocabularyDefinition<String>(
    id: GameVocabularyIds.platform,
    label: 'Platform',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_platformCatalogValues),
    builtIns: [
      'PlayStation 5',
      'PlayStation 4',
      'PlayStation 3',
      'PlayStation 2',
      'PlayStation',
      'PlayStation Portable',
      'PlayStation Vita',
      'Nintendo Switch',
      'Nintendo Wii U',
      'Nintendo Wii',
      'Nintendo GameCube',
      'Nintendo 64',
      'Super Nintendo Entertainment System',
      'Nintendo Entertainment System',
      'Nintendo 3DS',
      'Nintendo DS',
      'Game Boy Advance',
      'Game Boy Color',
      'Game Boy',
      'Xbox Series X/S',
      'Xbox One',
      'Xbox 360',
      'Xbox',
      'PC',
      'Sega Dreamcast',
      'Sega Saturn',
      'Sega Genesis',
    ],
  );

  static const region = VocabularyDefinition<String>(
    id: GameVocabularyIds.region,
    label: 'Region',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_regionCatalogValues),
    builtIns: [
      'NTSC-U/C (US/Canada)',
      'PAL (Europe/Australia)',
      'NTSC-J (Japan)',
      'NTSC-C (China)',
      'Region Free',
    ],
  );

  static const edition = VocabularyDefinition<String>(
    id: GameVocabularyIds.edition,
    label: 'Edition / Format',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_editionCatalogValues),
    builtIns: [
      'Standard Edition',
      "Collector's Edition",
      'Limited Edition',
      'Deluxe Edition',
      'Steelbook Edition',
      'Day One Edition',
      'Game of the Year Edition',
      'Complete Edition',
      'Greatest Hits / Platinum',
    ],
  );

  static const ageRating = VocabularyDefinition<String>(
    id: GameVocabularyIds.ageRating,
    label: 'Age Rating',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_ageRatingCatalogValues),
    builtIns: [
      'ESRB: Everyone (E)',
      'ESRB: Everyone 10+ (E10+)',
      'ESRB: Teen (T)',
      'ESRB: Mature 17+ (M)',
      'ESRB: Adults Only 18+ (AO)',
      'PEGI 3',
      'PEGI 7',
      'PEGI 12',
      'PEGI 16',
      'PEGI 18',
      'CERO A',
      'CERO B',
      'CERO C',
      'CERO D',
      'CERO Z',
    ],
  );

  static const condition = VocabularyDefinition<String>(
    id: GameVocabularyIds.condition,
    label: 'Condition',
    builtIns: [
      'Brand New / Sealed',
      'Complete in Box (CIB)',
      'Boxed (Missing Manual)',
      'Loose / Cartridge Only',
      'Disc Only',
      'Digital / Code',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    platform,
    region,
    edition,
    ageRating,
    condition,
  ];
}

Iterable<String?> _platformCatalogValues(GameCatalogMetadata metadata) sync* {
  yield* vocabularyValues([metadata.platform, metadata.platforms]);
}

Iterable<String?> _regionCatalogValues(GameCatalogMetadata metadata) {
  return vocabularyValues([metadata.releaseRegion]);
}

Iterable<String?> _editionCatalogValues(GameCatalogMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.edition,
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
  ]);
}

Iterable<String?> _ageRatingCatalogValues(GameCatalogMetadata metadata) {
  return vocabularyValues([metadata.ageRating]);
}
