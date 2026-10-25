import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:flutter/material.dart';

import 'game_add_search_controls.dart';

GameCatalogMetadata _metadata(CatalogSearchCandidate item) =>
    item.kindCapability.mapTransport(
        (transport) => GameCatalogMetadata.fromJson(transport.kindData));

String _platform(CatalogSearchCandidate item) =>
    _metadata(item).platforms.firstOrNull?.trim() ?? '';

/// As in the reference, a game is listed once per platform and its editions
/// are picked by cover, captioned with the edition title or barcode and the
/// release region.
final gameAddResultGrouping = LibraryAddResultGrouping(
  groupKey: (item) =>
      '${item.summary.primaryLabel.trim().toLowerCase()}|${_platform(item).toLowerCase()}',
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
);
