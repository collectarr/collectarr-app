import 'package:collectarr_app/features/library/kinds/registry/library_kind_capabilities.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_bundle.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

List<Widget> buildLibraryDetailEditorSections({
  required LibraryKindRegistration type,
  required LibraryProjectionView item,
  required Color accent,
  OwnedItemSummary? ownedItem,
  TrackingSummary? trackingSummary,
  TrackingRecord? trackingLifecycle,
}) {
  return [
    if (trackingSummary != null && trackingLifecycle != null)
      InspectorTrackingDetailsEditor(
        itemId: item.node.titleItemId,
        mediaType: item.source.mediaKind.apiValue,
        trackingLifecycle: trackingLifecycle,
        profile: type.trackingProfile,
        trackingEditor: type.inspector.trackingEditor,
        releases: type.presentation.builder.buildWorkspaceReleases(
          item.source,
        ),
        accent: accent,
      ),
  ];
}

List<Widget> buildLibraryInspectorEditorSections({
  required LibraryKindRegistration type,
  required LibraryProjectionView item,
  required Color accent,
  OwnedItemSummary? ownedItem,
  TrackingSummary? trackingSummary,
  TrackingRecord? trackingLifecycle,
}) {
  return buildLibraryDetailEditorSections(
    type: type,
    item: item,
    accent: accent,
    ownedItem: ownedItem,
    trackingLifecycle: trackingLifecycle,
    trackingSummary: trackingSummary,
  );
}

List<Widget> buildLibraryDetailKindSections({
  required BuildContext context,
  required LibraryKindRegistration type,
  required LibraryProjectionView item,
  required Color accent,
  ValueChanged<String>? onFilterByValue,
}) {
  return type.presentation.builder.buildInspectorSections(
    context: context,
    item: item,
    accent: accent,
    onFilterByValue: onFilterByValue,
  );
}

List<Widget> buildLibraryInspectorKindSections({
  required BuildContext context,
  required LibraryKindRegistration type,
  required LibraryProjectionView item,
  required Color accent,
  ValueChanged<String>? onFilterByValue,
}) {
  return buildLibraryDetailKindSections(
    context: context,
    type: type,
    item: item,
    accent: accent,
    onFilterByValue: onFilterByValue,
  );
}
