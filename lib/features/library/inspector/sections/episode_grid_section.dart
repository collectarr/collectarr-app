import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/video/video_episode_rating_section.dart';
import 'package:collectarr_app/features/library/kinds/video/video_season_tracking_section.dart';
import 'package:flutter/material.dart';

class InspectorEpisodeGridSection extends StatelessWidget {
  const InspectorEpisodeGridSection({
    super.key,
    required this.seriesRef,
    required this.kind,
    required this.accent,
    required this.itemId,
  });

  final CatalogEntityRef seriesRef;
  final String kind;
  final Color accent;
  final String itemId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VideoSeasonTrackingSection(
          seriesRef: seriesRef,
          kind: kind,
          accent: accent,
        ),
        const SizedBox(height: 8),
        VideoEpisodeRatingDisplaySection(
          itemId: itemId,
          kind: kind,
          accent: accent,
        ),
      ],
    );
  }
}
