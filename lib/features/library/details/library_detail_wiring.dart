import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

List<Widget> buildLibraryDetailEditorSections({
  required LibraryKindRegistration type,
  required LibraryProjectionView item,
  required Color accent,
  OwnedCopySummary? ownedItem,
  TrackingSummary? trackingSummary,
}) {
  return [
    if (trackingSummary != null)
      InspectorTrackingDetailsEditor(
        trackingSummary: trackingSummary,
        profile: libraryTrackingProfileForKind(type.kind),
        trackingEditor: libraryInspectorForKind(type.kind).trackingEditor,
        accent: accent,
      ),
  ];
}

List<Widget> buildLibraryInspectorEditorSections({
  required LibraryKindRegistration type,
  required LibraryProjectionView item,
  required Color accent,
  OwnedCopySummary? ownedItem,
  TrackingSummary? trackingSummary,
}) {
  return buildLibraryDetailEditorSections(
    type: type,
    item: item,
    accent: accent,
    ownedItem: ownedItem,
    trackingSummary: trackingSummary,
  );
}
