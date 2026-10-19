// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/dev/seeds/dev_seed_kind_contributor.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/dev/seeds/game_seeds.dart';
import 'package:collectarr_app/dev/seeds/music_seeds.dart';
export 'package:collectarr_app/dev/seeds/game_seeds.dart';
export 'package:collectarr_app/dev/seeds/music_seeds.dart';

final List<DevSeedKindContributor> collectarrDevSeedContributors = [
  gameDevSeedContributor,
  musicDevSeedContributor,
];

final Map<CatalogMediaKind, DevSeedKindContributor>
    collectarrDevSeedContributorsByKind = {
  CatalogMediaKind.game: gameDevSeedContributor,
  CatalogMediaKind.music: musicDevSeedContributor,
};
