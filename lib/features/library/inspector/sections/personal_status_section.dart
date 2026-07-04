import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_media_sections.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class InspectorPersonalStatusSection extends StatelessWidget {
  const InspectorPersonalStatusSection({
    super.key,
    required this.entry,
    required this.accent,
    this.ownedItem,
    this.trackingEntry,
    this.onFilterByValue,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return InspectorPersonalSection(
      entry: entry,
      ownedItem: ownedItem,
      trackingEntry: trackingEntry,
      accent: accent,
      onFilterByValue: onFilterByValue,
    );
  }
}
