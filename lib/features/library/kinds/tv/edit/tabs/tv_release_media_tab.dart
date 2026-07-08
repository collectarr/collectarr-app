import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_controller.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvReleaseMediaTab extends ConsumerWidget {
  const TvReleaseMediaTab({
    super.key,
    required this.accent,
    required this.videoEdit,
  });

  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Release media',
          accent: accent,
          child: FutureBuilder<TvSeries?>(
            future: videoEdit.tvSeriesFuture ??= videoEdit.loadTvSeriesSnapshot(),
            builder: (context, snapshot) {
              final series = snapshot.data ?? videoEdit.tvSeriesSnapshot;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  series == null) {
                return const EditSectionStateMessage(
                  message: 'Loading TV release media...',
                  icon: Icons.hourglass_empty,
                );
              }
              if (series == null) {
                return const EditSectionStateMessage(
                  message: 'No TV series data is available for this item yet.',
                  icon: Icons.tv_off_outlined,
                );
              }
              final media = videoEdit.tvReleaseMediaDraft.isEmpty
                  ? videoEdit.buildFallbackTvReleaseMedia(series)
                  : videoEdit.tvReleaseMediaDraft;
              if (media.isEmpty) {
                return const EditSectionStateMessage(
                  message: 'No release media is available for this series.',
                  icon: Icons.album_outlined,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EditSectionStateMessage(
                    message:
                        'Disc metadata is editable here; episode assignments are staged in the Episode map tab.',
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 12),
                  for (final disc in media)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 0,
                        color: appPalette(context).panelRaised,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.album_outlined,
                                    size: 18,
                                    color: appPalette(context).textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    disc.title ?? 'Disc ${disc.discNumber ?? 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Disc ${disc.discNumber ?? 1}',
                                    style: TextStyle(
                                      color: appPalette(context).textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (disc.formatLabel != null) ...[
                                const SizedBox(height: 8),
                                Text('Format: ${disc.formatLabel}'),
                              ],
                              if (disc.features.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Features: ${disc.features.join(', ')}'),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
