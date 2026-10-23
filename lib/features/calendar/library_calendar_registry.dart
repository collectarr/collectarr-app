import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/game_hardware_module.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/game_toy_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';

/// Calendar's explicit semantic composition root.
///
/// Calendar owns event hosting and rendering; each kind owns the meaning of
/// its release dates and event titles.
final Map<CatalogMediaKind, LibraryCalendarContributor>
    libraryCalendarContributorsByKind = {
  CatalogMediaKind.music: const MusicCalendarContributor(),
  CatalogMediaKind.game: const GameCalendarContributor(),
  CatalogMediaKind.gameHardware: const GameHardwareCalendarContributor(),
  CatalogMediaKind.gameToy: const GameToyCalendarContributor(),
};
