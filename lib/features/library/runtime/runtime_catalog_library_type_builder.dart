import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/anime/presentation.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation.dart';
import 'package:collectarr_app/features/library/kinds/generic/presentation.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation.dart';
import 'package:collectarr_app/features/library/runtime/library_catalog_resolution.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

LibraryTypeConfig buildRuntimeCatalogLibraryTypeConfig(CatalogMediaType type) {
  final normalizedType = normalizeCatalogMediaTypeDefaults(type);
  final presentation = _presentationForCatalogKind(normalizedType.kind);
  return LibraryTypeConfig(
    workspace: LibraryWorkspaceConfig(
      kind: normalizedType.kind,
      title: catalogDisplayLabel(
        normalizedType.pluralLabel,
        normalizedType.kind,
        plural: true,
      ),
      icon: libraryIconForKind(normalizedType.kind),
      preferencePrefix: 'catalog_${normalizedType.kind}',
      defaultSortColumn: LibrarySortColumn.title,
      defaultVisibleColumns: presentation.defaultVisibleColumns,
    ),
    singularLabel: catalogDisplayLabel(
      normalizedType.singularLabel,
      normalizedType.kind,
    ),
    pluralLabel: catalogDisplayLabel(
      normalizedType.pluralLabel,
      normalizedType.kind,
      plural: true,
    ),
    defaultMetadataProvider: normalizedType.defaultProvider ??
        (normalizedType.providers.isEmpty ? '' : normalizedType.providers.first),
    metadataProviders: const [],
    trackingProfile: catalogTrackingProfileForKind(normalizedType.kind),
    presentation: presentation,
  ).resolveWithCatalog([normalizedType]);
}

LibraryMediaPresentation _presentationForCatalogKind(String kind) {
  switch (kind.trim().toLowerCase()) {
    case 'anime':
      return animeLibraryMediaPresentation;
    case 'boardgame':
      return boardGamesLibraryMediaPresentation;
    case 'book':
      return booksLibraryMediaPresentation;
    case 'comic':
      return comicsLibraryMediaPresentation;
    case 'game':
      return gamesLibraryMediaPresentation;
    case 'manga':
      return mangaLibraryMediaPresentation;
    case 'movie':
      return moviesLibraryMediaPresentation;
    case 'music':
      return musicLibraryMediaPresentation;
    case 'tv':
      return tvLibraryMediaPresentation;
    default:
      return genericLibraryMediaPresentation;
  }
}