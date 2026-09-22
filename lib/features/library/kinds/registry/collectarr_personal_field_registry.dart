import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/metadata/library_field_ownership.dart';
import 'package:collectarr_app/features/library/metadata/library_personal_field_contributor.dart';

final Map<CatalogMediaKind, LibraryPersonalFieldContributor>
    collectarrKindPersonalFieldContributors = Map.unmodifiable({
  CatalogMediaKind.anime: animeKindPersonalFieldContributor,
  CatalogMediaKind.boardgame: const LibraryPersonalFieldContributor(
    kind: CatalogMediaKind.boardgame,
    fields: [],
  ),
  CatalogMediaKind.book: bookKindPersonalFieldContributor,
  CatalogMediaKind.comic: comicKindPersonalFieldContributor,
  CatalogMediaKind.game: gameKindPersonalFieldContributor,
  CatalogMediaKind.manga: mangaKindPersonalFieldContributor,
  CatalogMediaKind.movie: movieKindPersonalFieldContributor,
  CatalogMediaKind.music: musicKindPersonalFieldContributor,
  CatalogMediaKind.tv: tvKindPersonalFieldContributor,
});

final List<PersonalLibraryFieldSpec> libraryPersonalFields =
    List.unmodifiable(_deduplicateFields([
  ...kUniversalPersonalLibraryFields,
  for (final contributor in collectarrKindPersonalFieldContributors.values)
    ...contributor.fields,
]));

final List<PersonalLibraryFieldSpec> librarySyncablePersonalFields =
    List.unmodifiable(
  libraryPersonalFields.where((field) => field.syncable),
);

bool isPersonalLibraryField(String key) =>
    libraryPersonalFields.any((field) => field.key == key);

bool isSyncablePersonalField(String key) =>
    librarySyncablePersonalFields.any((field) => field.key == key);

List<PersonalLibraryFieldSpec> _deduplicateFields(
  Iterable<PersonalLibraryFieldSpec> fields,
) {
  final seen = <String>{};
  return [
    for (final field in fields)
      if (seen.add(field.key)) field
  ];
}
