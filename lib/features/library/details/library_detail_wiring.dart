import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

List<Widget> buildLibraryDetailEditorSections({
  required LibraryKindRuntime type,
  required LibraryProjectionRuntime item,
  required Color accent,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
}) {
  final catalogItem = item.source.catalogItem;
  return [
    if (ownedItem != null)
      InspectorPersonalDetailsEditor(
        ownedItem: ownedItem,
        accent: accent,
      ),
    if (trackingEntry != null)
      InspectorTrackingDetailsEditor(
        itemId: item.node.titleItemId,
        mediaType: catalogItem?.kind ?? '',
        trackingEntry: trackingEntry,
        profile: type.trackingProfile,
        trackingEditor: type.inspector.trackingEditor,
        editions: catalogItem == null
            ? const []
            : type.presentation.builder.buildReleaseEditions(
                item: catalogItem,
              ),
        accent: accent,
      ),
  ];
}

List<Widget> buildLibraryInspectorEditorSections({
  required LibraryKindRuntime type,
  required LibraryProjectionRuntime item,
  required Color accent,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
}) {
  return buildLibraryDetailEditorSections(
    type: type,
    item: item,
    accent: accent,
    ownedItem: ownedItem,
    trackingEntry: trackingEntry,
  );
}

List<Widget> buildLibraryDetailKindSections({
  required BuildContext context,
  required LibraryKindRuntime type,
  required LibraryProjectionRuntime item,
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
  required LibraryKindRuntime type,
  required LibraryProjectionRuntime item,
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
