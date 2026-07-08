import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class VideoEditDiscsTab extends StatelessWidget {
  const VideoEditDiscsTab({
    super.key,
    required this.item,
    required this.accent,
  });

  final LibraryMetadataItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final allDiscs = <(String, CatalogDisc)>[];
    for (final edition in item.editions) {
      for (final disc in edition.discs) {
        allDiscs.add((edition.title, disc));
      }
    }
    return EditTabShell(
      children: [
        EditSection(
          title: 'Provider disc metadata',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EditSectionStateMessage(
                message: 'Read-only: disc metadata is synced from provider/Core metadata.',
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 10),
              if (allDiscs.isEmpty)
                const EditSectionStateMessage(
                  message: 'No disc data available yet.',
                  icon: Icons.album_outlined,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (editionTitle, disc) in allDiscs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.album, size: 16, color: appPalette(context).textMuted),
                            const SizedBox(width: 8),
                            Text(disc.discName ?? 'Disc ${disc.discNumber}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            if (disc.discFormat != null) ...[
                              const SizedBox(width: 6),
                              Text('(${disc.discFormat})', style: TextStyle(color: appPalette(context).textMuted)),
                            ],
                            const Spacer(),
                            Text(editionTitle, style: TextStyle(color: appPalette(context).textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        EditSection(
          title: 'Local disc notes',
          accent: accent,
          child: const EditSectionStateMessage(
            message: 'Use the release details tab for package/disc notes and the episode map tab for disc assignments.',
            icon: Icons.edit_note,
          ),
        ),
      ],
    );
  }
}
