import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_ownership_capability.dart';
import 'package:collectarr_app/features/library/config/library_provider_preview_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';

final Map<CatalogMediaKind, LibraryOwnershipCapability>
    collectarrKindOwnershipCapabilities =
    Map.unmodifiable(<CatalogMediaKind, LibraryOwnershipCapability>{
  CatalogMediaKind.anime: const LibraryOwnershipCapability.allowEverywhere(),
  CatalogMediaKind.boardgame:
      const LibraryOwnershipCapability.allowEverywhere(),
  CatalogMediaKind.book: const LibraryOwnershipCapability.allowEverywhere(),
  CatalogMediaKind.comic: const LibraryOwnershipCapability.allowEverywhere(),
  CatalogMediaKind.game: const LibraryOwnershipCapability.allowEverywhere(),
  CatalogMediaKind.manga: const LibraryOwnershipCapability.allowEverywhere(),
  CatalogMediaKind.movie: const LibraryOwnershipCapability.allowEverywhere(),
  CatalogMediaKind.music: musicKindOwnership,
  CatalogMediaKind.tv: const LibraryOwnershipCapability.allowEverywhere(),
});

final Map<CatalogMediaKind, LibraryProviderPreviewPolicy>
    collectarrKindProviderPreviewPolicies =
    Map.unmodifiable(<CatalogMediaKind, LibraryProviderPreviewPolicy>{
  CatalogMediaKind.anime: const LibraryProviderPreviewPolicy(),
  CatalogMediaKind.boardgame: const LibraryProviderPreviewPolicy(),
  CatalogMediaKind.book: const LibraryProviderPreviewPolicy(),
  CatalogMediaKind.comic: const LibraryProviderPreviewPolicy(),
  CatalogMediaKind.game: const LibraryProviderPreviewPolicy(),
  CatalogMediaKind.manga: const LibraryProviderPreviewPolicy(),
  CatalogMediaKind.movie: const LibraryProviderPreviewPolicy(),
  CatalogMediaKind.music: musicKindProviderPreviewPolicy,
  CatalogMediaKind.tv: const LibraryProviderPreviewPolicy(),
});
