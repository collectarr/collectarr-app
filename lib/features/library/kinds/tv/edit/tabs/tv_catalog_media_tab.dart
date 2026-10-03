import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_edit_controller.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TvCatalogMediaTab extends StatelessWidget {
  const TvCatalogMediaTab({
    super.key,
    required this.accent,
    required this.mediaEdit,
  });

  final Color accent;
  final TvMediaEditController mediaEdit;

  @override
  Widget build(BuildContext context) {
    final media = mediaEdit.tvMediaDraft;
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
                    'Media and episode assignments are stored in the Catalog Item document.',
                icon: Icons.info_outline,
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
                            Icon(
                              Icons.album_outlined,
                              size: 16,
                              color: appPalette(context).textMuted,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              row.title ??
                                  row.mediaType ??
                                  'Media ${row.position}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Text(
                              'Media ${row.mediaNumber ?? row.position}',
                              style: TextStyle(
                                color: appPalette(context).textMuted,
                                fontSize: 12,
                              ),
                            ),
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
