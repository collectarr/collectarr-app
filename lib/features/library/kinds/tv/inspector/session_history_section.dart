import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
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
  final CatalogItemRef catalogRef;

  @override
  Widget build(BuildContext context) {
    return WatchHistorySection(
      libraryEntryRef: request.libraryEntry?.ref ??
          LibraryEntryRef(
            kind: catalogRef.kind,
            id: LibraryEntryId(request.item.source.itemId),
          ),
      accent: request.accent,
    );
  }
}
