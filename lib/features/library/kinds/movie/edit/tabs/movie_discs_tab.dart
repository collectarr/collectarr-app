import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MovieEditDiscsTab extends StatelessWidget {
  const MovieEditDiscsTab({
    super.key,
    required this.item,
    required this.accent,
  });

  final CatalogSearchCandidate item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final payload =
        item.kindCapability.mapTransport((transport) => transport).payload;
    final rawMedia = payload['media'] ?? payload['discs'];
    final media = rawMedia is Iterable
        ? [
            for (final value in rawMedia)
              if (value is Map)
                MovieCatalogItemMedia.fromJson(
                  Map<String, dynamic>.from(value),
                ),
          ]
        : const <MovieCatalogItemMedia>[];
    return EditTabShell(
      children: [
        EditSection(
          title: 'Disc and media contents',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EditSectionStateMessage(
                message: 'Read-only catalog contents for this Movie item.',
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 10),
              if (media.isEmpty)
                const EditSectionStateMessage(
                  message: 'No disc data available yet.',
                  icon: Icons.album_outlined,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final disc in media)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.album,
                                size: 16, color: appPalette(context).textMuted),
                            const SizedBox(width: 8),
                            Text(disc.title ?? 'Disc ${disc.mediaNumber}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            if (disc.formatLabel != null) ...[
                              const SizedBox(width: 6),
                              Text('(${disc.formatLabel})',
                                  style: TextStyle(
                                      color: appPalette(context).textMuted)),
                            ],
                            if (disc.numDiscs != null) ...[
                              const Spacer(),
                              Text('${disc.numDiscs} disc(s)',
                                  style: TextStyle(
                                      color: appPalette(context).textMuted,
                                      fontSize: 12)),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
