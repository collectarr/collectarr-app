import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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

class LibraryInspectorPanelLayout extends StatelessWidget {
  const LibraryInspectorPanelLayout({
    super.key,
    required this.entry,
    required this.ownedItem,
    required this.accent,
    required this.children,
    this.panelPadding = const EdgeInsets.fromLTRB(8, 0, 8, 12),
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;
  final List<Widget> children;
  final EdgeInsetsGeometry panelPadding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          left: BorderSide(
            color: accent.withValues(alpha: palette.isDark ? 0.3 : 0.22),
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: InspectorBackdrop(entry: entry, ownedItem: ownedItem),
          ),
          ListView(
            padding: panelPadding,
            children: children,
          ),
        ],
      ),
    );
  }
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