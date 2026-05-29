import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

typedef TrackingFieldWidgetBuilder = Widget Function(
  TextEditingController controller,
  String label,
);

List<Widget> buildTrackingProgressFieldWidgets({
  required TrackingFieldWidgetBuilder buildField,
  required TextEditingController progressCurrentController,
  required TextEditingController progressTotalController,
  required TextEditingController timesCompletedController,
}) {
  return [
    buildField(progressCurrentController, 'Progress current'),
    buildField(progressTotalController, 'Progress total'),
    buildField(timesCompletedController, 'Times completed'),
  ];
}

List<Widget> buildTrackingEpisodeFieldWidgets({
  required TrackingFieldWidgetBuilder buildField,
  required TextEditingController seasonNumberController,
  required TextEditingController episodeNumberController,
}) {
  return [
    buildField(seasonNumberController, 'Season'),
    buildField(episodeNumberController, 'Episode'),
  ];
}

class TrackingQuickAdjustments extends StatelessWidget {
  const TrackingQuickAdjustments({
    super.key,
    required this.accent,
    required this.progressCurrentController,
    required this.progressTotalController,
    required this.seasonNumberController,
    required this.episodeNumberController,
    required this.showsEpisodeFields,
    required this.onDecrementProgress,
    required this.onIncrementProgress,
    required this.onDecrementEpisode,
    required this.onIncrementEpisode,
  });

  final Color accent;
  final TextEditingController progressCurrentController;
  final TextEditingController progressTotalController;
  final TextEditingController seasonNumberController;
  final TextEditingController episodeNumberController;
  final bool showsEpisodeFields;
  final VoidCallback onDecrementProgress;
  final VoidCallback onIncrementProgress;
  final VoidCallback onDecrementEpisode;
  final VoidCallback onIncrementEpisode;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        progressCurrentController,
        progressTotalController,
        seasonNumberController,
        episodeNumberController,
      ]),
      builder: (context, child) {
        final progressCurrent = parseTrackingInt(progressCurrentController.text) ?? 0;
        final progressTotal = parseTrackingInt(progressTotalController.text);
        final seasonNumber = parseTrackingInt(seasonNumberController.text);
        final episodeNumber = parseTrackingInt(episodeNumberController.text);
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickTrackingStepper(
              accent: accent,
              label: trackingProgressSummaryLabel(
                progressCurrent: progressCurrent,
                progressTotal: progressTotal,
              ),
              onDecrement: onDecrementProgress,
              onIncrement: onIncrementProgress,
            ),
            if (showsEpisodeFields)
              _QuickTrackingStepper(
                accent: accent,
                label: trackingEpisodeSummaryLabel(
                  seasonNumber: seasonNumber,
                  episodeNumber: episodeNumber,
                ),
                onDecrement: onDecrementEpisode,
                onIncrement: onIncrementEpisode,
              ),
          ],
        );
      },
    );
  }
}

String trackingProgressSummaryLabel({
  required int progressCurrent,
  int? progressTotal,
}) {
  if (progressTotal != null && progressTotal > 0) {
    return 'Watched ep $progressCurrent/$progressTotal';
  }
  return 'Progress $progressCurrent';
}

String trackingEpisodeSummaryLabel({
  int? seasonNumber,
  int? episodeNumber,
}) {
  final resolvedEpisode = episodeNumber ?? 1;
  if (seasonNumber != null) {
    return 'S$seasonNumber · Ep $resolvedEpisode';
  }
  return 'Episode $resolvedEpisode';
}

int clampTrackingProgress({
  required int current,
  required int delta,
  int? progressTotal,
}) {
  final next = current + delta;
  if (progressTotal != null && progressTotal > 0) {
    return next.clamp(0, progressTotal);
  }
  return next < 0 ? 0 : next;
}

int clampTrackingEpisode({
  required int current,
  required int delta,
}) {
  final next = current + delta;
  return next < 1 ? 1 : next;
}

int? parseTrackingInt(String value) {
  return int.tryParse(value.trim());
}

class _QuickTrackingStepper extends StatelessWidget {
  const _QuickTrackingStepper({
    required this.accent,
    required this.label,
    required this.onDecrement,
    required this.onIncrement,
  });

  final Color accent;
  final String label;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withValues(alpha: 0.82),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Decrease',
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            IconButton(
              tooltip: 'Increase',
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}