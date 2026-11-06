import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/cover_preview.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:flutter/material.dart';

/// The edition shown in the Add dialog's confirm sheet, with its edition and
/// region as details.
Widget buildGameAddPreview(
    BuildContext context, LibraryAddPreviewPaneRequest request) {
  final item = request.item;
  if (item == null) return const SizedBox.shrink();
  final game = item.kindCapability.mapTransport(
      (transport) => GameCatalogMetadata.fromJson(transport.kindData));
  final platform = game.platforms.firstOrNull?.trim() ?? '';
  final edition = game.editionTitle?.trim() ?? '';
  final region = game.releaseRegion?.trim() ?? '';
  return LibraryAddCoverPreview(
    title: game.title,
    mediaKind: item.summary.kind,
    imageUrl: item.summary.imageUrl,
    accent: request.accent,
    platform: platform,
    year: game.releaseDateParts?.year,
    ebayQuery: '${game.title} $platform',
    details: [
      if (edition.isNotEmpty) edition,
      if (region.isNotEmpty) region,
      if (game.barcode case final barcode? when edition.isEmpty) barcode,
    ],
  );
}
