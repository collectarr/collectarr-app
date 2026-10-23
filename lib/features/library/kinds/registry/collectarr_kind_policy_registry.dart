import 'package:collectarr_app/features/library/kinds/registry/library_release_scope.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_entries_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';

final Map<CatalogMediaKind, LibraryEntryPolicyCapability>
    collectarrKindEntryPolicyCapabilities =
    releasedKindContributions(<CatalogMediaKind, LibraryEntryPolicyCapability>{
  CatalogMediaKind.anime: const LibraryEntryPolicyCapability.allowEverywhere(),
  CatalogMediaKind.boardgame:
      const LibraryEntryPolicyCapability.allowEverywhere(),
  CatalogMediaKind.book: const LibraryEntryPolicyCapability.allowEverywhere(),
  CatalogMediaKind.comic: const LibraryEntryPolicyCapability.allowEverywhere(),
  CatalogMediaKind.game: const LibraryEntryPolicyCapability.allowEverywhere(),
  CatalogMediaKind.gameHardware:
      const LibraryEntryPolicyCapability.allowEverywhere(),
  CatalogMediaKind.gameToy:
      const LibraryEntryPolicyCapability.allowEverywhere(),
  CatalogMediaKind.movie: const LibraryEntryPolicyCapability.allowEverywhere(),
  CatalogMediaKind.music: musicKindEntryPolicy,
});
