import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

@immutable
class LibraryInspectorSectionSpec {
  const LibraryInspectorSectionSpec({
    required this.title,
    required this.children,
    this.accentColor,
    this.collapsible = true,
    this.initiallyExpanded = true,
  });

  final String title;
  final List<Widget> children;
  final Color? accentColor;
  final bool collapsible;
  final bool initiallyExpanded;
}

List<Widget> buildLibraryInspectorSectionList(
  Iterable<Widget?> sections, {
  double spacing = 8,
}) {
  final resolved = <Widget>[];
  for (final section in sections) {
    if (section == null) {
      continue;
    }
    if (resolved.isNotEmpty) {
      resolved.add(SizedBox(height: spacing));
    }
    resolved.add(section);
  }
  return resolved;
}

List<Widget> buildLibraryInspectorSectionWidgets(
  Iterable<LibraryInspectorSectionSpec?> sections, {
  double spacing = 8,
}) {
  final resolved = <Widget>[];
  for (final section in sections) {
    if (section == null) {
      continue;
    }
    if (resolved.isNotEmpty) {
      resolved.add(SizedBox(height: spacing));
    }
    resolved.add(
      section.accentColor == null
          ? LibraryInspectorSection(
              title: section.title,
              collapsible: section.collapsible,
              initiallyExpanded: section.initiallyExpanded,
              children: section.children,
            )
          : LibraryInspectorSection(
              title: section.title,
              accentColor: section.accentColor!,
              collapsible: section.collapsible,
              initiallyExpanded: section.initiallyExpanded,
              children: section.children,
            ),
    );
  }
  return resolved;
}

List<Widget> buildLibraryInspectorEditorSections({
  required LibraryTypeConfig type,
  required LibraryWorkspaceEntry entry,
  required Color accent,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
}) {
  return [
    if (ownedItem != null)
      InspectorPersonalDetailsEditor(
        ownedItem: ownedItem,
        accent: accent,
      ),
    if (trackingEntry != null)
      InspectorTrackingDetailsEditor(
        itemId: entry.id,
        mediaType: entry.mediaType,
        trackingEntry: trackingEntry,
        profile: type.trackingProfile,
        editions: entry.editions,
        accent: accent,
      ),
  ];
}

List<Widget> buildLibraryInspectorKindSections({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryWorkspaceEntry entry,
  required Color accent,
  ValueChanged<String>? onFilterByValue,
}) {
  return type.presentation.builder.buildInspectorSections(
    context: context,
    entry: entry,
    accent: accent,
    onFilterByValue: onFilterByValue,
  );
}