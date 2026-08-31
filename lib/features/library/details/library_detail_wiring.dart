import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

List<Widget> buildLibraryDetailEditorSections({
  required LibraryTypeConfig type,
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
        editions: catalogItem?.editions ?? const [],
        accent: accent,
      ),
  ];
}

List<Widget> buildLibraryInspectorEditorSections({
  required LibraryTypeConfig type,
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
  required LibraryTypeConfig type,
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
  required LibraryTypeConfig type,
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
