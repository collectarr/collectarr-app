import 'package:flutter/material.dart';

class EpisodicTrackingDraft {
  EpisodicTrackingDraft({
    required this.seasonNumberController,
    required this.episodeNumberController,
    required this.episodeRatings,
  });

  final TextEditingController seasonNumberController;
  final TextEditingController episodeNumberController;
  Map<String, int> episodeRatings;
}
