import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shows a small popup to pick a 1–10 rating for a specific episode.
/// Returns the selected rating, or null if dismissed / cleared.
Future<int?> showEpisodeRatingPicker({
  required BuildContext context,
  required int season,
  required int episode,
  int? currentRating,
}) async {
  return showDialog<int>(
    context: context,
    builder: (context) => _EpisodeRatingPickerDialog(
      season: season,
      episode: episode,
      currentRating: currentRating,
    ),
  );
}

class _EpisodeRatingPickerDialog extends StatelessWidget {
  const _EpisodeRatingPickerDialog({
    required this.season,
    required this.episode,
    this.currentRating,
  });

  final int season;
  final int episode;
  final int? currentRating;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return AlertDialog(
      backgroundColor: palette.panel,
      title: Text(
        'S$season E$episode',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: onSurface,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      content: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (var i = 1; i <= 10; i++)
            _RatingChip(
              value: i,
              selected: i == currentRating,
              onTap: () => Navigator.of(context).pop(i),
            ),
        ],
      ),
      actions: [
        if (currentRating != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(0),
            child: const Text('Clear'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final hue = ((value - 1) / 9 * 120).clamp(0.0, 120.0);
    final color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.35).toColor();
    return Material(
      color: selected ? color : color.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: selected ? Colors.white : onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
