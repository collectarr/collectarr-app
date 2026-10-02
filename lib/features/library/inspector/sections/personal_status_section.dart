import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class InspectorPersonalStatusSection extends StatelessWidget {
  const InspectorPersonalStatusSection({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    this.collectionItem,
    this.collectionItemDispatch,
    this.trackingSummary,
    this.onFilterByValue,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final CollectionItemSummary? collectionItem;
  final LibraryCollectionItemDispatch? collectionItemDispatch;
  final TrackingSummary? trackingSummary;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return InspectorPersonalSection(
      type: type,
      item: item,
      collectionItem: collectionItem,
      collectionItemDispatch: collectionItemDispatch,
      trackingSummary: trackingSummary,
      accent: accent,
      onFilterByValue: onFilterByValue,
    );
  }
}
