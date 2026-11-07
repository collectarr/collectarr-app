import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/cover_preview.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_metadata.dart';
import 'package:flutter/material.dart';

/// The hardware shown in the Add dialog's confirm sheet.
Widget buildGameHardwareAddPreview(
    BuildContext context, LibraryAddPreviewPaneRequest request) {
  final item = request.item;
  if (item == null) return const SizedBox.shrink();
  final hardware = item.kindCapability.mapTransport(
      (transport) => GameHardwareCatalogMetadata.fromJson(transport.kindData));
  final platform = hardware.platform?.trim() ?? '';
  return LibraryAddCoverPreview(
    title: hardware.title,
    mediaKind: item.summary.kind,
    imageUrl: item.summary.imageUrl,
    accent: request.accent,
    iconLabel: platformIconLabel(platform),
    year: hardware.releaseDateParts?.year,
    ebayQuery: '${hardware.title} $platform',
    details: [
      if (hardware.hardwareType?.trim() case final type? when type.isNotEmpty)
        type,
    ],
  );
}
