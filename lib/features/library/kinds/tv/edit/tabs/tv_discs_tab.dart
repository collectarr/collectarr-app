import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TvEditDiscsTab extends StatelessWidget {
  const TvEditDiscsTab({
    super.key,
    required this.item,
    required this.accent,
  });

  final CatalogSearchCandidate item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final media = item.kindCapability.mapTransport(
      (transport) => TvSeriesMetadata.fromJson(transport.kindData).media,
    );
    return EditTabShell(
      children: [
        EditSection(
          title: 'Catalog media',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EditSectionStateMessage(
                message:
                    'Read-only: media metadata is supplied by the catalog document.',
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 10),
              if (media.isEmpty)
                const EditSectionStateMessage(
                  message: 'No media data available yet.',
                  icon: Icons.album_outlined,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final row in media)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.album_outlined,
                                size: 16, color: appPalette(context).textMuted),
                            const SizedBox(width: 8),
                            Text(
                                row.title ??
                                    row.mediaType ??
                                    'Media ${row.position}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text('Media ${row.mediaNumber ?? row.position}',
                                style: TextStyle(
                                    color: appPalette(context).textMuted,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        EditSection(
          title: 'Local media notes',
          accent: accent,
          child: const EditSectionStateMessage(
            message:
                'Use the personal details tab for package notes. Episode-to-media assignments remain kind-owned.',
            icon: Icons.edit_note,
          ),
        ),
      ],
    );
  }
}
