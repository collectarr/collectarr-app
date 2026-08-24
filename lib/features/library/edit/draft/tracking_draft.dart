import 'package:flutter/material.dart';

/// Draft containing universal tracking-specific fields.
class TrackingDraft {
  TrackingDraft({
    required this.ratingController,
    required this.trackingController,
    required this.progressCurrentController,
    required this.progressTotalController,
    required this.timesCompletedController,
    required this.trackingNotesController,
    required this.selectedTrackingEditionId,
    required this.selectedTrackingVariantId,
    required this.startedAt,
    required this.finishedAt,
  });

  final TextEditingController ratingController;
  final TextEditingController trackingController;
  final TextEditingController progressCurrentController;
  final TextEditingController progressTotalController;
  final TextEditingController timesCompletedController;
  final TextEditingController trackingNotesController;

  String? selectedTrackingEditionId;
  String? selectedTrackingVariantId;
  DateTime? startedAt;
  DateTime? finishedAt;
}
