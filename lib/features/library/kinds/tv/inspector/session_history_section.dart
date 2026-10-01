import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/tracking/session_history_section.dart';
import 'package:flutter/material.dart';

class InspectorSessionHistorySection extends StatelessWidget {
  const InspectorSessionHistorySection({
    super.key,
    required this.request,
    required this.catalogRef,
  });

  final LibraryInspectorRequest request;
  final CatalogEntityRef catalogRef;

  @override
  Widget build(BuildContext context) {
    return WatchHistorySection(
      catalogRef: catalogRef,
      accent: request.accent,
      defaultTargetRef: catalogRef,
    );
  }
}
