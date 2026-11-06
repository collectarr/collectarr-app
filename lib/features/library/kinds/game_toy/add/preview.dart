import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/cover_preview.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_metadata.dart';
import 'package:flutter/material.dart';

/// The toy shown in the Add dialog's confirm sheet.
Widget buildGameToyAddPreview(
    BuildContext context, LibraryAddPreviewPaneRequest request) {
  final item = request.item;
  if (item == null) return const SizedBox.shrink();
  final toy = item.kindCapability.mapTransport(
      (transport) => GameToyCatalogMetadata.fromJson(transport.kindData));
  return LibraryAddCoverPreview(
    title: toy.title,
    mediaKind: item.summary.kind,
    imageUrl: item.summary.imageUrl,
    accent: request.accent,
    year: toy.releaseDateParts?.year,
    ebayQuery: toy.title,
    details: [
      for (final detail in [toy.seriesTitle, toy.toyType, toy.toySubtype])
        if (detail?.trim() case final text? when text.isNotEmpty) text,
    ],
  );
}
