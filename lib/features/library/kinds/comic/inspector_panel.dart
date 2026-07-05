import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_shared_sections.dart';
import 'package:flutter/material.dart';

Widget buildComicInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return ComicInspectorPanel(request: request);
}

class ComicInspectorPanel extends StatelessWidget {
  const ComicInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final accent = request.inspector.accent;
    final entry = request.inspector.entry;
    final ownedItem = request.inspector.ownedItem;
    final children = <Widget>[
      InspectorUnifiedToolbar(
        entry: entry,
        onEdit: request.onEdit,
        onShare: request.onShare,
        onDuplicate: request.onDuplicate,
        onToggleOwned: request.onToggleOwned,
        onLoan: request.onLoan,
        onRefreshMetadata: request.onRefreshMetadata,
        onUnlinkFromCore: request.onUnlinkFromCore,
        onDetailsLayoutChanged: request.onDetailsLayoutChanged,
      ),
      const SizedBox(height: 8),
      request.hero,
      ...buildLibraryInspectorSectionList([
        request.ownedCopiesSection,
        request.bundleSection,
        request.conditionGradeSection,
        if (request.primarySections.isNotEmpty) ...request.primarySections,
        if (request.trailingSections.isNotEmpty) ...request.trailingSections,
      ]      ),
      const SizedBox(height: 6),
      ...buildLibraryInspectorSectionFlow(
        bodySections: [
          request.ownedCopiesSection,
          request.bundleSection,
          request.conditionGradeSection,
          ...request.primarySections,
        ],
        afterBodySections: request.trailingSections,
      ),
    ];

    return LibraryInspectorPanelLayout(
      entry: entry,
      ownedItem: ownedItem,
      accent: accent,
      children: children,
    );
  }
}
