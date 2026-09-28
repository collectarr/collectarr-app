import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_kind_identity.dart';
import 'package:flutter/material.dart';

/// Identity data needed by the Catalog Item v1 shell, with no legacy
/// provider, Work/Release, or kind capability dependencies.
const catalogItemV1KindIdentities = <CatalogMediaKind, LibraryKindIdentity>{
  CatalogMediaKind.anime: LibraryKindIdentity(
    kind: CatalogMediaKind.anime,
    singularLabel: 'Anime',
    pluralLabel: 'Anime',
    title: 'Anime',
    icon: Icons.movie_filter_outlined,
    accent: Color(0xFFC94DFF),
    preferencePrefix: 'anime',
    routeSegments: ['anime'],
    mediaFamily: 'video',
  ),
  CatalogMediaKind.boardgame: LibraryKindIdentity(
    kind: CatalogMediaKind.boardgame,
    singularLabel: 'Board Game',
    pluralLabel: 'Board Games',
    title: 'Board Games',
    icon: Icons.casino_outlined,
    accent: Color(0xFFE0A52B),
    preferencePrefix: 'boardgames',
    routeSegments: ['board-games', 'boardgames', 'boardgame'],
    mediaFamily: 'game',
    normalizeCatalogLabels: true,
  ),
  CatalogMediaKind.book: LibraryKindIdentity(
    kind: CatalogMediaKind.book,
    singularLabel: 'Book',
    pluralLabel: 'Books',
    title: 'Books',
    icon: Icons.book_outlined,
    accent: Color(0xFFC78446),
    preferencePrefix: 'books',
    routeSegments: ['books', 'book'],
    mediaFamily: 'print',
  ),
  CatalogMediaKind.comic: LibraryKindIdentity(
    kind: CatalogMediaKind.comic,
    singularLabel: 'Comic',
    pluralLabel: 'Comics',
    title: 'Comics',
    icon: Icons.collections_bookmark_outlined,
    accent: Color(0xFF44BFE7),
    preferencePrefix: 'comics',
    routeSegments: ['comics', 'comic'],
    mediaFamily: 'print',
  ),
  CatalogMediaKind.game: LibraryKindIdentity(
    kind: CatalogMediaKind.game,
    singularLabel: 'Game',
    pluralLabel: 'Games',
    title: 'Games',
    icon: Icons.sports_esports,
    accent: Color(0xFFF64458),
    preferencePrefix: 'games',
    routeSegments: ['games', 'game'],
    mediaFamily: 'game',
  ),
  CatalogMediaKind.manga: LibraryKindIdentity(
    kind: CatalogMediaKind.manga,
    singularLabel: 'Manga',
    pluralLabel: 'Manga',
    title: 'Manga',
    icon: Icons.import_contacts_outlined,
    accent: Color(0xFFFF6F91),
    preferencePrefix: 'manga',
    routeSegments: ['manga'],
    mediaFamily: 'print',
  ),
  CatalogMediaKind.movie: LibraryKindIdentity(
    kind: CatalogMediaKind.movie,
    singularLabel: 'Movie',
    pluralLabel: 'Movies',
    title: 'Movies',
    icon: Icons.movie_outlined,
    accent: Color(0xFF42AA55),
    preferencePrefix: 'movies',
    routeSegments: ['movies', 'movie'],
    mediaFamily: 'video',
  ),
  CatalogMediaKind.music: LibraryKindIdentity(
    kind: CatalogMediaKind.music,
    singularLabel: 'Music',
    pluralLabel: 'Music',
    title: 'Music',
    icon: Icons.music_note,
    accent: Color(0xFFF2932F),
    preferencePrefix: 'music',
    routeSegments: ['music'],
    mediaFamily: 'audio',
    normalizeCatalogLabels: true,
  ),
  CatalogMediaKind.tv: LibraryKindIdentity(
    kind: CatalogMediaKind.tv,
    singularLabel: 'TV Show',
    pluralLabel: 'TV Shows',
    title: 'TV',
    icon: Icons.tv_outlined,
    accent: Color(0xFF00A7A0),
    preferencePrefix: 'tv',
    routeSegments: ['tv', 'tv-shows', 'tvshows'],
    mediaFamily: 'video',
    normalizeCatalogLabels: true,
  ),
};

LibraryKindIdentity catalogItemV1IdentityForKind(CatalogMediaKind kind) {
  final identity = catalogItemV1KindIdentities[kind];
  if (identity == null) {
    throw ArgumentError.value(
        kind, 'kind', 'A known library kind is required.');
  }
  return identity;
}
