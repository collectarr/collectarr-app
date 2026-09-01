import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/book/book_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/game/game_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/music/music_physical_media_formats.dart';

const allKnownPhysicalMediaFormats = [
  ...videoPhysicalMediaFormats,
  ...musicPhysicalMediaFormats,
  ...bookPhysicalMediaFormats,
  ...comicPhysicalMediaFormats,
  ...gamePhysicalMediaFormats,
];

List<PhysicalMediaFormat> kindFallbackPhysicalMediaFormats(
  CatalogMediaKind kind,
) {
  return switch (kind) {
    CatalogMediaKind.anime ||
    CatalogMediaKind.movie ||
    CatalogMediaKind.tv => videoPhysicalMediaFormats,
    CatalogMediaKind.boardgame || CatalogMediaKind.game => gamePhysicalMediaFormats,
    CatalogMediaKind.book || CatalogMediaKind.manga => bookPhysicalMediaFormats,
    CatalogMediaKind.comic => comicPhysicalMediaFormats,
    CatalogMediaKind.music => musicPhysicalMediaFormats,
    CatalogMediaKind.unknown => const [],
  };
}