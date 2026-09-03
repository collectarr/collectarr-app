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
  });

  final Set<CatalogMediaKind> activeKinds;
  final Map<String, Set<CatalogMediaKind>> mandatoryParticipants;
  final Map<String, Set<CatalogMediaKind>> optionalParticipants;
}

const kindContractManifest = KindContractManifest(
  activeKinds: activeTypedKinds,
  mandatoryParticipants: {
    'coreMapping': activeTypedKinds,
    'repository': activeTypedKinds,
    'mediaPersistence': activeTypedKinds,
    'workspace': activeTypedKinds,
    'fields': activeTypedKinds,
    'add': activeTypedKinds,
    'mediaEdit': activeTypedKinds,
    'identity': activeTypedKinds,
  },
  optionalParticipants: {
    'release': {
      CatalogMediaKind.anime,
      CatalogMediaKind.movie,
      CatalogMediaKind.tv,
    },
    'releaseEdit': {
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
      CatalogMediaKind.tv,
    },
    'releasePersistence': {
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
      CatalogMediaKind.tv,
    },
    'tracking': activeTypedKinds,
    'hierarchy': activeTypedKinds,
    'providerIntegration': activeTypedKinds,
  },
);
