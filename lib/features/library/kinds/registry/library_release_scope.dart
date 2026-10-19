import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Product scope for the public release. Dormant source contributions are not
/// registered, rendered, queried or persisted through the active registries.
const releasedLibraryKinds = <CatalogMediaKind>{
  CatalogMediaKind.music,
  CatalogMediaKind.game,
};

Map<CatalogMediaKind, T> releasedKindContributions<T>(
  Map<CatalogMediaKind, T> contributions,
) =>
    Map.unmodifiable({
      for (final entry in contributions.entries)
        if (releasedLibraryKinds.contains(entry.key)) entry.key: entry.value,
    });
