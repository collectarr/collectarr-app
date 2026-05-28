import 'dart:math' as math;

import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Key format for episode ratings: "s{season}e{episode}".
String episodeRatingKey(int season, int episode) => 's${season}e$episode';

/// Parse a rating key back to (season, episode).
({int season, int episode})? parseEpisodeRatingKey(String key) {
  final match = RegExp(r'^s(\d+)e(\d+)$').firstMatch(key);
  if (match == null) return null;
  return (
    season: int.parse(match.group(1)!),
    episode: int.parse(match.group(2)!),
  );
}

/// Callback when a user taps a cell to set/edit a rating.
typedef EpisodeRatingCallback = void Function(
  int season,
  int episode,
  int? currentRating,
);

/// Heatmap grid showing per-episode ratings across seasons.
///
/// Columns = seasons (S1, S2, …), rows = episodes (E1, E2, …).
/// Each cell is color-coded from yellow (low) to green (high).
/// Bottom row shows the average rating per season.
class EpisodeRatingGrid extends StatelessWidget {
  const EpisodeRatingGrid({
    super.key,
    required this.seasons,
    required this.ratings,
    this.onRatingTap,
    this.cellSize = 38,
    this.headerStyle,
    this.compact = false,
  });

  final List<Season> seasons;
  final Map<String, int> ratings;
  final EpisodeRatingCallback? onRatingTap;
  final double cellSize;
  final TextStyle? headerStyle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedSeasons = List<Season>.from(seasons)
      ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

    final maxEpisodes = sortedSeasons.fold<int>(
      0,
      (max, s) => math.max(max, s.episodes.length),
    );

    if (maxEpisodes == 0) {
      return const SizedBox.shrink();
    }

    final labelWidth = compact ? 32.0 : 42.0;
    final effectiveCellSize = compact ? 32.0 : cellSize;
    final fontSize = compact ? 10.0 : 12.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row: labels + season columns
          _HeaderRow(
            seasons: sortedSeasons,
            labelWidth: labelWidth,
            cellSize: effectiveCellSize,
            fontSize: fontSize,
            headerStyle: headerStyle,
          ),
          const SizedBox(height: 2),
          // Episode rows
          for (var ep = 1; ep <= maxEpisodes; ep++)
            _EpisodeRow(
              episodeNumber: ep,
              seasons: sortedSeasons,
              ratings: ratings,
              onRatingTap: onRatingTap,
              labelWidth: labelWidth,
              cellSize: effectiveCellSize,
              fontSize: fontSize,
            ),
          const SizedBox(height: 4),
          // Average row
          _AverageRow(
            seasons: sortedSeasons,
            ratings: ratings,
            maxEpisodes: maxEpisodes,
            labelWidth: labelWidth,
            cellSize: effectiveCellSize,
            fontSize: fontSize,
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.seasons,
    required this.labelWidth,
    required this.cellSize,
    required this.fontSize,
    this.headerStyle,
  });

  final List<Season> seasons;
  final double labelWidth;
  final double cellSize;
  final double fontSize;
  final TextStyle? headerStyle;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final style = headerStyle ??
        TextStyle(
          color: palette.textMuted,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: labelWidth),
        for (final season in seasons)
          SizedBox(
            width: cellSize,
            height: cellSize * 0.7,
            child: Center(
              child: Text(
                'S${season.seasonNumber}',
                style: style,
              ),
            ),
          ),
      ],
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({
    required this.episodeNumber,
    required this.seasons,
    required this.ratings,
    required this.onRatingTap,
    required this.labelWidth,
    required this.cellSize,
    required this.fontSize,
  });

  final int episodeNumber;
  final List<Season> seasons;
  final Map<String, int> ratings;
  final EpisodeRatingCallback? onRatingTap;
  final double labelWidth;
  final double cellSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: labelWidth,
          height: cellSize,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                'E$episodeNumber',
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        for (final season in seasons)
          _RatingCell(
            season: season.seasonNumber,
            episode: episodeNumber,
            hasEpisode: episodeNumber <= season.episodes.length,
            rating: ratings[episodeRatingKey(season.seasonNumber, episodeNumber)],
            onTap: onRatingTap,
            size: cellSize,
            fontSize: fontSize,
          ),
      ],
    );
  }
}

class _RatingCell extends StatelessWidget {
  const _RatingCell({
    required this.season,
    required this.episode,
    required this.hasEpisode,
    required this.rating,
    required this.onTap,
    required this.size,
    required this.fontSize,
  });

  final int season;
  final int episode;
  final bool hasEpisode;
  final int? rating;
  final EpisodeRatingCallback? onTap;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    if (!hasEpisode) {
      return SizedBox(width: size, height: size);
    }

    final color = rating != null ? _ratingColor(rating!) : null;
    final textColor = rating != null
        ? (ThemeData.estimateBrightnessForColor(color!) == Brightness.dark
            ? Colors.white
            : Colors.black87)
      : palette.textMuted;

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Material(
      color: color ?? palette.surfaceSubtle.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap == null
              ? null
              : () => onTap!(season, episode, rating),
          child: SizedBox(
            width: size - 2,
            height: size - 2,
            child: Center(
              child: Text(
                rating?.toString() ?? '—',
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AverageRow extends StatelessWidget {
  const _AverageRow({
    required this.seasons,
    required this.ratings,
    required this.maxEpisodes,
    required this.labelWidth,
    required this.cellSize,
    required this.fontSize,
  });

  final List<Season> seasons;
  final Map<String, int> ratings;
  final int maxEpisodes;
  final double labelWidth;
  final double cellSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: labelWidth,
          height: cellSize,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                'Avg',
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        for (final season in seasons) _averageCell(context, season),
      ],
    );
  }

  Widget _averageCell(BuildContext context, Season season) {
    final palette = appPalette(context);
    final seasonRatings = <int>[];
    for (var ep = 1; ep <= season.episodes.length; ep++) {
      final r = ratings[episodeRatingKey(season.seasonNumber, ep)];
      if (r != null) seasonRatings.add(r);
    }

    if (seasonRatings.isEmpty) {
      return SizedBox(width: cellSize, height: cellSize);
    }

    final avg = seasonRatings.reduce((a, b) => a + b) / seasonRatings.length;
    final color = _ratingColor(avg.round());
    final textColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: palette.divider.withValues(alpha: 0.7)),
        ),
        child: SizedBox(
          width: cellSize - 2,
          height: cellSize - 2,
          child: Center(
            child: Text(
              avg.toStringAsFixed(1),
              style: TextStyle(
                color: textColor,
                fontSize: fontSize - 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Maps a 1–10 rating to a heatmap color.
/// 1–3: red, 4–5: orange, 6–7: yellow-green, 8–9: green, 10: bright green.
Color _ratingColor(int rating) {
  final clamped = rating.clamp(1, 10);
  // Hue: 0° (red) → 120° (green), mapped from rating 1→10
  final hue = ((clamped - 1) / 9 * 120).clamp(0.0, 120.0);
  final saturation = 0.65 + (clamped / 10 * 0.2);
  final lightness = clamped <= 5 ? 0.38 : 0.32 + (clamped - 5) / 10 * 0.1;
  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}
