import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/result_policy.dart';
import 'package:collectarr_app/features/library/entries/record.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:flutter/material.dart';

import 'search_controls.dart';

GameCatalogMetadata _metadata(CatalogSearchCandidate item) =>
    item.kindCapability.mapTransport(
        (transport) => GameCatalogMetadata.fromJson(transport.kindData));

String _platform(CatalogSearchCandidate item) =>
    _metadata(item).platforms.firstOrNull?.trim() ?? '';

/// One game on one platform by its title, which also matches the games
/// already in the collection.
String gameAddItemGroupKey(CatalogSearchCandidate item) =>
    '${item.summary.primaryLabel.trim().toLowerCase()}|${_platform(item).toLowerCase()}';

/// The game a result belongs to: its Core Game ID, which Core gives every
/// edition of one game on one platform; a result without one falls back to
/// its title and platform.
String gameAddResultGroupKey(CatalogSearchCandidate item) =>
    switch (_metadata(item).gameId) {
      final gameId? => 'game:$gameId',
      null => gameAddItemGroupKey(item),
    };

/// As in the reference, a game is listed once per platform and its editions
/// are picked by cover, captioned with the edition title or barcode and the
/// release region.
final gameAddResultGrouping = LibraryAddResultGrouping(
  groupKey: gameAddResultGroupKey,
  groupDetail: (context, item) {
    final platform = _platform(item);
    if (platform.isEmpty) return const SizedBox.shrink();
    return Row(children: [
      PlatformIcon(platform, size: 17),
      const SizedBox(width: 6),
      Flexible(child: Text(platform)),
    ]);
  },
  variantLabel: (item) {
    final metadata = _metadata(item);
    final edition = metadata.editionTitle?.trim() ?? '';
    return edition.isNotEmpty ? edition : metadata.barcode?.trim() ?? '';
  },
  variantBadge: (item) {
    final region = gameAddRegionFor(_metadata(item).releaseRegion);
    return region == null || region == GameAddRegion.other ? '' : region.label;
  },
  // The reference's region segments above the editions.
  variantFacet: LibraryAddVariantFacet(
    segments: [
      for (final region in GameAddRegion.values)
        (value: region.value, label: region.label)
    ],
    valueOf: (item) => gameAddRegionFor(_metadata(item).releaseRegion)?.value,
  ),
);

/// The group a library entry belongs to, as [gameAddResultGrouping] keys a
/// Core result.
String? gameAddEntryGroupKey(LibraryEntryRecord entry) {
  final metadata = GameCatalogMetadata.fromJson(entry.catalogData);
  final title = metadata.title.trim().toLowerCase();
  if (title.isEmpty) return null;
  final platform = metadata.platforms.firstOrNull?.trim().toLowerCase() ?? '';
  return '$title|$platform';
}
