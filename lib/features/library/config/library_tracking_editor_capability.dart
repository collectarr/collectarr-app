import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:flutter/material.dart';

/// A kind-owned mutation applied to the common lifecycle entry at save time.
///
/// The host does not know which fields the mutation changes. This keeps kind
/// coordinates and other semantic tracking state behind the owning kind.
typedef TrackingEntryEditMutation = TrackingEntry Function(
  TrackingEntry entry,
);

typedef TrackingEditorExtensionBuilder = Widget Function(
  BuildContext context, {
  required TrackingEntry entry,
  required ValueChanged<TrackingEntryEditMutation> onChanged,
  required Color accent,
});

/// Optional kind-owned extension for the generic tracking editor shell.
class LibraryTrackingEditorCapability {
  const LibraryTrackingEditorCapability({required this.builder});

  final TrackingEditorExtensionBuilder builder;

  Widget build(
    BuildContext context, {
    required TrackingEntry entry,
    required ValueChanged<TrackingEntryEditMutation> onChanged,
    required Color accent,
  }) {
    return builder(
      context,
      entry: entry,
      onChanged: onChanged,
      accent: accent,
    );
  }
}
