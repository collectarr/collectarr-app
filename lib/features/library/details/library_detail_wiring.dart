import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

List<Widget> buildLibraryDetailEditorSections({
  required LibraryKindModule type,
  required LibraryProjectionView item,
  required Color accent,
  OwnedItemSummary? ownedItem,
  TrackingLifecycle? trackingLifecycle,
}) {
  final catalogItem = item.source.catalogTransport;
  return [
    if (trackingLifecycle != null)
      InspectorTrackingDetailsEditor(
        itemId: item.node.titleItemId,
        mediaType: catalogItem?.mediaKind.apiValue ?? '',
        trackingLifecycle: trackingLifecycle,
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
  required LibraryKindModule type,
  required LibraryProjectionView item,
  required Color accent,
  OwnedItemSummary? ownedItem,
  TrackingLifecycle? trackingLifecycle,
}) {
  return buildLibraryDetailEditorSections(
    type: type,
    item: item,
    accent: accent,
    ownedItem: ownedItem,
    trackingLifecycle: trackingLifecycle,
  );
}

List<Widget> buildLibraryDetailKindSections({
  required BuildContext context,
  required LibraryKindModule type,
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
  required LibraryKindModule type,
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
