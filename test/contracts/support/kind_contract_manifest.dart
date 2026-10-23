import 'package:collectarr_app/core/models/catalog_media_kind.dart';

const activeTypedKinds = <CatalogMediaKind>{
  CatalogMediaKind.comic,
  CatalogMediaKind.anime,
  CatalogMediaKind.book,
  CatalogMediaKind.game,
  CatalogMediaKind.gameHardware,
  CatalogMediaKind.gameToy,
  CatalogMediaKind.boardgame,
  CatalogMediaKind.movie,
  CatalogMediaKind.music,
};

final class KindContractManifest {
  const KindContractManifest({
    required this.activeKinds,
    required this.mandatoryParticipants,
    required this.optionalParticipants,
  });

  final Set<CatalogMediaKind> activeKinds;
  final Map<String, Set<CatalogMediaKind>> mandatoryParticipants;
  final Map<String, Set<CatalogMediaKind>> optionalParticipants;
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
    'entry': activeTypedKinds,
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
    },
    'releaseRepository': {
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
    'releaseProjection': {
      CatalogMediaKind.anime,
      CatalogMediaKind.movie,
    },
    'releaseEdit': {
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
    'releasePersistence': {
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
    'calendar': activeTypedKinds,
    'activity': {
      CatalogMediaKind.anime,
    },
    'tracking': {
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
    'hierarchy': {
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
  },
);
