import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The edition shown in the Add dialog's confirm sheet: cover beside title,
/// platform and year, then the edition and region, as in the reference.
Widget buildGameAddPreview(
    BuildContext context, LibraryAddPreviewPaneRequest request) {
  final item = request.item;
  if (item == null) return const SizedBox.shrink();
  final game = item.kindCapability.mapTransport(
      (transport) => GameCatalogMetadata.fromJson(transport.kindData));
  final palette = appPalette(context);
  final platform = game.platforms.firstOrNull?.trim() ?? '';
  final year = game.releaseDateParts?.year;
  final edition = game.editionTitle?.trim() ?? '';
  final region = game.releaseRegion?.trim() ?? '';
  return DefaultTextStyle.merge(
    style: TextStyle(fontSize: 14, height: 20 / 14, color: palette.textPrimary),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.square(
            dimension: 210,
            child: LibraryInteractiveCover(
              title: game.title,
              imageUrl: item.summary.imageUrl,
              accentColor: request.accent,
              fallbackAspectRatio: 1,
              borderRadius: 0,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.title,
                    style: const TextStyle(
                        fontSize: 24,
                        height: 26 / 24,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (platform.isNotEmpty || year != null)
                  Row(children: [
                    if (platform.isNotEmpty) ...[
                      PlatformIcon(platform, size: 24),
                      const SizedBox(width: 5),
                      Flexible(child: Text(platform)),
                    ],
                    if (year != null)
                      Text(' ($year)',
                          style: TextStyle(
                              color: palette.isDark
                                  ? const Color(0xff888888)
                                  : palette.textMuted)),
                  ]),
                const SizedBox(height: 13),
                if (edition.isNotEmpty) Text(edition),
                if (region.isNotEmpty) Text(region),
                if (game.barcode case final barcode? when edition.isEmpty)
                  Text(barcode),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
