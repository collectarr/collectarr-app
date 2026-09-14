import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

List<Widget> buildLibraryDetailEditorSections({
  required LibraryKindRegistration type,
  required LibraryProjectionView item,
  required Color accent,
  OwnedItemSummary? ownedItem,
  TrackingSummary? trackingSummary,
}) {
  return [
    if (trackingSummary != null)
      InspectorTrackingDetailsEditor(
        itemId: item.node.titleItemId,
        mediaType: item.source.mediaKind.apiValue,
        trackingSummary: trackingSummary,
        profile: libraryTrackingProfileForKind(type.kind),
        trackingEditor: libraryInspectorForKind(type.kind).trackingEditor,
        releases: libraryPresentationForKind(type.kind).builder.buildWorkspaceReleases(
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
}) {
  return buildLibraryDetailEditorSections(
    type: type,
    item: item,
    accent: accent,
    ownedItem: ownedItem,
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
  return libraryPresentationForKind(type.kind).builder.buildInspectorSections(
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
