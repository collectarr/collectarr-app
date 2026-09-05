import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/actions/import_export_actions.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/calendar/anime_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/barcode/anime_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/calendar/boardgame_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/barcode/boardgame_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/book/barcode/book_isbn_resolver.dart';
import 'package:collectarr_app/features/library/kinds/game/calendar/game_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/barcode/game_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/manga/calendar/manga_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/barcode/manga_identifier_resolver.dart';
import 'package:collectarr_app/features/library/kinds/movie/calendar/movie_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/barcode/movie_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/music/calendar/music_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/barcode/music_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/book/calendar/book_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/comic_info/comic_info_export.dart';
import 'package:collectarr_app/features/library/kinds/comic/calendar/comic_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/barcode/comic_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/collection_csv/comic_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_shelf/manga_collection_shelf_extension.dart';
import 'package:collectarr_app/features/library/kinds/tv/calendar/tv_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/barcode/tv_barcode_resolver.dart';
import 'package:collectarr_app/features/library/config/library_barcode_resolver.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';

final class LibraryKindRegistry {
  LibraryKindRegistry(
    Iterable<LibraryKindRuntime> specs,
  ) : _byKind = _buildValidatedRegistry(specs);

  final Map<CatalogMediaKind, LibraryKindRuntime> _byKind;

  static Map<CatalogMediaKind, LibraryKindRuntime> _buildValidatedRegistry(
    Iterable<LibraryKindRuntime> specs,
  ) {
    final map = <CatalogMediaKind, LibraryKindRuntime>{};
    for (final spec in specs) {
      if (map.containsKey(spec.kind)) {
        throw StateError(
          'Duplicate LibraryKindSpec registration for kind: ${spec.kind}',
        );
      }
      validateKindRuntime(spec);
      map[spec.kind] = spec;
    }
    return Map.unmodifiable(map);
  }

  LibraryKindRuntime require(CatalogMediaKind kind) {
    final runtime = _byKind[kind];
    if (runtime == null) {
      throw ArgumentError('No LibraryKindRuntime registered for kind: $kind');
    }
    return runtime;
  }

  LibraryKindRuntime? tryGet(CatalogMediaKind kind) => _byKind[kind];

  LibraryKindRuntime getByKind(CatalogMediaKind kind) => require(kind);

  List<LibraryKindRuntime> get allRuntimes => List.unmodifiable(_byKind.values);
}

final defaultLibraryKindRegistry = LibraryKindRegistry(collectarrKindModules);

final Map<CatalogMediaKind, LibraryCollectionCsvProjection>
    _collectionCsvProjections = Map.unmodifiable({
  CatalogMediaKind.comic: const ComicCollectionCsvProjection(),
});

Iterable<LibraryCollectionCsvProjection> get libraryCollectionCsvProjections =>
    _collectionCsvProjections.values;

final Map<CatalogMediaKind, LibraryCalendarContributor> _calendarContributors =
    Map.unmodifiable({
  CatalogMediaKind.anime: const AnimeCalendarContributor(),
  CatalogMediaKind.boardgame: const BoardGameCalendarContributor(),
  CatalogMediaKind.book: const BookCalendarContributor(),
  CatalogMediaKind.comic: const ComicCalendarContributor(),
  CatalogMediaKind.game: const GameCalendarContributor(),
  CatalogMediaKind.manga: const MangaCalendarContributor(),
  CatalogMediaKind.movie: const MovieCalendarContributor(),
  CatalogMediaKind.music: const MusicCalendarContributor(),
  CatalogMediaKind.tv: const TvCalendarContributor(),
});

Iterable<LibraryCalendarContributor> get libraryCalendarContributors =>
    _calendarContributors.values;

LibraryCalendarContributor? libraryCalendarContributorForKind(
  CatalogMediaKind kind,
) {
  return _calendarContributors[kind];
}

final Map<CatalogMediaKind, LibraryBarcodeResolver> _barcodeResolvers =
    Map.unmodifiable({
  CatalogMediaKind.anime: const AnimeBarcodeResolver(),
  CatalogMediaKind.boardgame: const BoardGameBarcodeResolver(),
  CatalogMediaKind.book: const BookIsbnResolver(),
  CatalogMediaKind.comic: const ComicBarcodeResolver(),
  CatalogMediaKind.game: const GameBarcodeResolver(),
  CatalogMediaKind.manga: const MangaIdentifierResolver(),
  CatalogMediaKind.movie: const MovieBarcodeResolver(),
  CatalogMediaKind.music: const MusicBarcodeResolver(),
  CatalogMediaKind.tv: const TvBarcodeResolver(),
});

Iterable<LibraryBarcodeResolver> get libraryBarcodeResolvers =>
    _barcodeResolvers.values;

LibraryBarcodeResolver? libraryBarcodeResolverForKind(CatalogMediaKind kind) =>
    _barcodeResolvers[kind];

/// Resolves a raw scanner/manual value through the owning kind.
///
/// The returned value is still only the identifier accepted by the boundary;
/// generic callers do not inspect or infer its domain meaning.
String? resolveLibraryBarcodeForKind(
  CatalogMediaKind kind,
  String rawValue,
) {
  final code = ScannedCode.tryFromRaw(rawValue);
  if (code == null) {
    return null;
  }
  return libraryBarcodeResolverForKind(kind)?.resolve(code);
}

/// Returns the kind-owned semantic CSV contribution for a serialization
/// boundary. The generic Collection feature receives cells only; it never
/// inspects Comic or another kind's domain fields.
LibraryCollectionCsvProjection? libraryCollectionCsvProjectionForKind(
  CatalogMediaKind kind,
) {
  return _collectionCsvProjections[kind];
}

/// Composition-root dispatch for kind-owned extensions on the mixed Shelf.
///
/// The Collection feature owns the slot and row lifecycle. It receives only a
/// widget contribution and does not import Manga hierarchy types or provider
/// code.
Widget? libraryShelfExtensionForEntry(
  ShelfEntry entry, {
  required bool expanded,
  required VoidCallback onToggle,
}) {
  return switch (catalogMediaKindFromValue(entry.catalogItem?.kind)) {
    CatalogMediaKind.manga => MangaCollectionShelfExtension(
        itemId: entry.itemId,
        expanded: expanded,
        onToggle: onToggle,
      ),
    _ => null,
  };
}

final libraryKindRegistryProvider = Provider<LibraryKindRegistry>((ref) {
  return defaultLibraryKindRegistry;
});

LibraryKindRuntime libraryKindRuntime(
  CatalogMediaKind kind, {
  LibraryKindRegistry? registry,
}) =>
    libraryKindRuntimeForKind(kind, registry: registry);

LibraryKindRuntime libraryKindRuntimeForKind(
  CatalogMediaKind kind, {
  LibraryKindRegistry? registry,
}) {
  final reg = registry ?? defaultLibraryKindRegistry;
  final runtime = reg.tryGet(kind);
  if (runtime != null) {
    return runtime;
  }
  if (kind.isUnknown) {
    return genericKindModule;
  }
  return reg.require(kind);
}

bool libraryGroupModeSupportsCompletion(
  LibraryKindRuntime type,
  String groupMode,
) {
  return type.groupModeSupportsCompletion(
    type.fields.decodeGroupId(groupMode),
  );
}

/// Composition-root contributions exposed to generic feature hosts.
///
/// The registry may assemble kind implementations; callers receive only the
/// structural artifact contract and never import a concrete kind.
List<ExportPreviewArtifact> libraryExportPreviewArtifacts(
  Iterable<ShelfEntry> entries,
) {
  return comicInfoExportPreviews(entries);
}
