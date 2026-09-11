import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class InspectorPersonalStatusSection extends StatelessWidget {
  const InspectorPersonalStatusSection({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    this.ownedItem,
    this.ownedItemDispatch,
    this.trackingLifecycle,
    this.onFilterByValue,
  });

  final LibraryKindModule type;
  final LibraryProjectionView item;
  final OwnedItemSummary? ownedItem;
  final LibraryOwnedItemDispatch? ownedItemDispatch;
  final TrackingLifecycle? trackingLifecycle;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return InspectorPersonalSection(
      type: type,
      item: item,
      ownedItem: ownedItem,
      ownedItemDispatch: ownedItemDispatch,
      trackingLifecycle: trackingLifecycle,
      accent: accent,
      onFilterByValue: onFilterByValue,
    );
  }
}
