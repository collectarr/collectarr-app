import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';

final Map<CatalogMediaKind, CollectionCsvKindProfile>
    collectionCsvProfilesByKind = {
  CatalogMediaKind.music: const MusicCollectionCsvProjection(),
  CatalogMediaKind.game: const GameCollectionCsvProjection(),
};
