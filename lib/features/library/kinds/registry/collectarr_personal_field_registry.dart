import 'package:collectarr_app/features/library/kinds/registry/library_release_scope.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/game_hardware_module.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/game_toy_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/metadata/library_field_entries.dart';
import 'package:collectarr_app/features/library/metadata/library_personal_field_contributor.dart';

final Map<CatalogMediaKind, LibraryPersonalFieldContributor>
    collectarrKindPersonalFieldContributors = releasedKindContributions({
  CatalogMediaKind.boardgame: boardGameKindPersonalFieldContributor,
  CatalogMediaKind.book: bookKindPersonalFieldContributor,
  CatalogMediaKind.comic: comicKindPersonalFieldContributor,
  CatalogMediaKind.game: gameKindPersonalFieldContributor,
  CatalogMediaKind.gameHardware: gameHardwareKindPersonalFieldContributor,
  CatalogMediaKind.gameToy: gameToyKindPersonalFieldContributor,
  CatalogMediaKind.movie: movieKindPersonalFieldContributor,
  CatalogMediaKind.music: musicKindPersonalFieldContributor,
});

final List<PersonalLibraryFieldSpec> libraryPersonalFields =
    List.unmodifiable(_deduplicateFields([
  for (final contributor in collectarrKindPersonalFieldContributors.values)
    ...contributor.fields,
]));

final List<PersonalLibraryFieldSpec> librarySyncablePersonalFields =
    List.unmodifiable(
  libraryPersonalFields.where((field) => field.syncable),
);

LibraryPersonalFieldContributor personalFieldContributorFor(
  CatalogMediaKind kind,
) {
  final contributor = collectarrKindPersonalFieldContributors[kind];
  if (contributor == null) {
    throw StateError('No personal field contributor is registered for $kind.');
  }
  return contributor;
}

List<PersonalLibraryFieldSpec> _deduplicateFields(
  Iterable<PersonalLibraryFieldSpec> fields,
) {
  final seen = <String>{};
  return [
    for (final field in fields)
      if (seen.add(field.key)) field
  ];
}
