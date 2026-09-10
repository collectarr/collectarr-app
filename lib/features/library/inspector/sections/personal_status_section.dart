import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class InspectorPersonalStatusSection extends StatelessWidget {
  const InspectorPersonalStatusSection({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    this.ownedItem,
    this.typedOwnedItem,
    this.trackingEntry,
    this.onFilterByValue,
  });

  final LibraryKindModule type;
  final LibraryProjectionView item;
  final OwnedItemSummary? ownedItem;
  final Object? typedOwnedItem;
  final TrackingEntry? trackingEntry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return InspectorPersonalSection(
      type: type,
      item: item,
      ownedItem: ownedItem,
      typedOwnedItem: typedOwnedItem,
      trackingEntry: trackingEntry,
      accent: accent,
      onFilterByValue: onFilterByValue,
    );
  }
}
