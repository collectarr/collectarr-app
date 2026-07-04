import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/video/watch_history_section.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:flutter/material.dart';

class InspectorSessionHistorySection extends StatelessWidget {
  const InspectorSessionHistorySection({
    super.key,
    required this.request,
    required this.seriesRef,
    required this.releaseOptions,
  });

  final LibraryInspectorRequest request;
  final CatalogEntityRef seriesRef;
  final List<WatchHistoryTargetOption> releaseOptions;

  @override
  Widget build(BuildContext context) {
    return WatchHistorySection(
      itemId: request.entry.id,
      accent: request.accent,
      catalogRef: seriesRef,
      defaultTargetRef: seriesRef,
      targetOptions: releaseOptions,
    );
  }
}
