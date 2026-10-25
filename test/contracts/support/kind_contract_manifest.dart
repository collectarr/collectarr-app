import 'package:collectarr_app/core/models/catalog_media_kind.dart';

const activeTypedKinds = <CatalogMediaKind>{
  CatalogMediaKind.comic,
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
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
    'releaseRepository': {
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
    'releaseProjection': {
      CatalogMediaKind.movie,
    },
    'releaseEdit': {
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
    'releasePersistence': {
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
    'calendar': activeTypedKinds,
    'activity': {},
    'tracking': {
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
    'hierarchy': {
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
    },
  },
);
