import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'tv_episode_thumbnail.dart';

class TvEpisodeRow extends StatelessWidget {
  const TvEpisodeRow({
    super.key,
    required this.accent,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    required this.overview,
    required this.airDate,
    required this.runtimeMinutes,
    required this.imageUrl,
    required this.fallbackImageUrl,
    required this.localImagePath,
    required this.thumbnailImageUrl,
    required this.discNumber,
    required this.watched,
    required this.rating,
    this.onEdit,
    this.onDelete,
  });

  final Color accent;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? overview;
  final String? airDate;
  final int? runtimeMinutes;
  final String? imageUrl;
  final String? fallbackImageUrl;
  final String? localImagePath;
  final String? thumbnailImageUrl;
  final int? discNumber;
  final bool watched;
  final int? rating;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final code =
        'S${seasonNumber.toString().padLeft(2, '0')}E${episodeNumber.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: appPalette(context).surfaceSubtle.withValues(alpha: 0.82),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: accent.withValues(alpha: 0.14)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TvEpisodeThumbnail(
                imageUrl: imageUrl,
                fallbackImageUrl: fallbackImageUrl,
                localImagePath: localImagePath,
                thumbnailImageUrl: thumbnailImageUrl,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$code • $title',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _pill(context, watched ? 'Watched' : 'Unwatched'),
                        if (airDate != null && airDate!.trim().isNotEmpty)
                          _pill(context, airDate!.trim()),
                        if (runtimeMinutes != null)
                          _pill(context, '$runtimeMinutes min'),
                        if (rating != null) _pill(context, 'Rating $rating'),
                        _pill(
                          context,
                          discNumber == null
                              ? 'No disc assignment'
                              : 'Disc $discNumber',
                        ),
                      ],
                    ),
                    if (overview != null && overview!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        overview!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: appPalette(context).textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  if (onEdit != null)
                    IconButton(
                      tooltip: 'Edit episode',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: 'Delete override',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _pill(BuildContext context, String label) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: appPalette(context).panel,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: appPalette(context).divider),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    ),
  );
}
