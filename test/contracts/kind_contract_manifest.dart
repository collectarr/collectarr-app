import 'package:collectarr_app/core/models/catalog_media_kind.dart';

const activeTypedKinds = <CatalogMediaKind>{
  CatalogMediaKind.comic,
  CatalogMediaKind.manga,
  CatalogMediaKind.anime,
  CatalogMediaKind.book,
  CatalogMediaKind.game,
  CatalogMediaKind.boardgame,
  CatalogMediaKind.movie,
  CatalogMediaKind.tv,
  CatalogMediaKind.music,
};

final class KindContractManifest {
  const KindContractManifest({
    required this.activeKinds,
    required this.mandatoryParticipants,
    required this.optionalParticipants,
    required this.providerKindParticipants,
  });

  final Set<CatalogMediaKind> activeKinds;
  final Map<String, Set<CatalogMediaKind>> mandatoryParticipants;
  final Map<String, Set<CatalogMediaKind>> optionalParticipants;
  final Map<String, Set<CatalogMediaKind>> providerKindParticipants;
}

const kindContractManifest = KindContractManifest(
  activeKinds: activeTypedKinds,
  mandatoryParticipants: {
    'coreFieldAdoption': activeTypedKinds,
    'coreMapping': activeTypedKinds,
    'repository': activeTypedKinds,
    'mediaPersistence': activeTypedKinds,
    'workspace': activeTypedKinds,
    'fields': activeTypedKinds,
    'sort': activeTypedKinds,
    'group': activeTypedKinds,
    'facet': activeTypedKinds,
    'vocabulary': activeTypedKinds,
    'add': activeTypedKinds,
    'mediaEdit': activeTypedKinds,
    'identity': activeTypedKinds,
    'owned': activeTypedKinds,
  },
  optionalParticipants: {
    'release': {
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
      CatalogMediaKind.tv,
    },
    'releaseRepository': {
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
      CatalogMediaKind.tv,
    },
    'releaseProjection': {
      CatalogMediaKind.anime,
      CatalogMediaKind.movie,
      CatalogMediaKind.tv,
    },
    'releaseEdit': {
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
      CatalogMediaKind.tv,
    },
    'releasePersistence': {
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
      CatalogMediaKind.tv,
    },
    'calendar': activeTypedKinds,
    'activity': {
      CatalogMediaKind.anime,
      CatalogMediaKind.tv,
    },
    'tracking': activeTypedKinds,
    'hierarchy': activeTypedKinds,
    'providerIntegration': activeTypedKinds,
  },
  providerKindParticipants: {
    'anilist': {
      CatalogMediaKind.anime,
      CatalogMediaKind.manga,
    },
    'bgg': {
      CatalogMediaKind.boardgame,
    },
    'comicvine': {
      CatalogMediaKind.comic,
      CatalogMediaKind.manga,
    },
    'gcd': {
      CatalogMediaKind.comic,
    },
    'hardcover': {
      CatalogMediaKind.book,
      CatalogMediaKind.manga,
    },
    'igdb': {
      CatalogMediaKind.game,
    },
    'mangadex': {
      CatalogMediaKind.manga,
    },
    'musicbrainz': {
      CatalogMediaKind.music,
    },
    'openlibrary': {
      CatalogMediaKind.book,
    },
    'tmdb': {
      CatalogMediaKind.anime,
      CatalogMediaKind.movie,
      CatalogMediaKind.tv,
    },
  },
);
