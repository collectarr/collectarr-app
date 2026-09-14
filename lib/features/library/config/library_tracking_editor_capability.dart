import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:flutter/material.dart';

/// Opaque kind-owned patch emitted by a tracking editor.
///
/// The host carries this value to the owning codec but never applies or
/// inspects it. This keeps hierarchy coordinates and other semantic state
/// inside the kind.
typedef TrackingLifecycleEditMutation = TrackingKindPatch;

typedef TrackingEditorExtensionBuilder = Widget Function(
  BuildContext context, {
  required TrackingSummary summary,
  required ValueChanged<TrackingLifecycleEditMutation> onChanged,
  required Color accent,
});

/// Optional kind-owned extension for the generic tracking editor shell.
class LibraryTrackingEditorCapability {
  const LibraryTrackingEditorCapability({required this.builder});

  final TrackingEditorExtensionBuilder builder;

  Widget build(
    BuildContext context, {
    required TrackingSummary summary,
    required ValueChanged<TrackingLifecycleEditMutation> onChanged,
    required Color accent,
  }) {
    return builder(
      context,
      summary: summary,
      onChanged: onChanged,
      accent: accent,
    );
  }
}
