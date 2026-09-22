import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/metadata/library_field_ownership.dart';
import 'package:collectarr_app/features/library/metadata/library_personal_field_contributor.dart';

final Map<CatalogMediaKind, LibraryPersonalFieldContributor>
    collectarrKindPersonalFieldContributors = Map.unmodifiable({
  CatalogMediaKind.anime: const LibraryPersonalFieldContributor(
    kind: CatalogMediaKind.anime,
    fields: [],
  ),
  CatalogMediaKind.boardgame: const LibraryPersonalFieldContributor(
    kind: CatalogMediaKind.boardgame,
    fields: [],
  ),
  CatalogMediaKind.book: const LibraryPersonalFieldContributor(
    kind: CatalogMediaKind.book,
    fields: [],
  ),
  CatalogMediaKind.comic: comicKindPersonalFieldContributor,
  CatalogMediaKind.game: gameKindPersonalFieldContributor,
  CatalogMediaKind.manga: const LibraryPersonalFieldContributor(
    kind: CatalogMediaKind.manga,
    fields: [],
  ),
  CatalogMediaKind.movie: const LibraryPersonalFieldContributor(
    kind: CatalogMediaKind.movie,
    fields: [],
  ),
  CatalogMediaKind.music: const LibraryPersonalFieldContributor(
    kind: CatalogMediaKind.music,
    fields: [],
  ),
  CatalogMediaKind.tv: const LibraryPersonalFieldContributor(
    kind: CatalogMediaKind.tv,
    fields: [],
  ),
});

final List<PersonalLibraryFieldSpec> libraryPersonalFields = List.unmodifiable([
  ...kUniversalPersonalLibraryFields,
  for (final contributor in collectarrKindPersonalFieldContributors.values)
    ...contributor.fields,
]);

final List<PersonalLibraryFieldSpec> librarySyncablePersonalFields =
    List.unmodifiable(
  libraryPersonalFields.where((field) => field.syncable),
);

bool isPersonalLibraryField(String key) =>
    libraryPersonalFields.any((field) => field.key == key);

bool isSyncablePersonalField(String key) =>
    librarySyncablePersonalFields.any((field) => field.key == key);
