import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
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
      if (request.ownedCopiesSection != null) ...[
        const SizedBox(height: 8),
        request.ownedCopiesSection!,
      ],
      if (request.bundleSection != null) ...[
        const SizedBox(height: 8),
        request.bundleSection!,
      ],
      if (request.conditionGradeSection != null) ...[
        const SizedBox(height: 8),
        request.conditionGradeSection!,
      ],
      if (request.primarySections.isNotEmpty) ...[
        const SizedBox(height: 8),
        ...request.primarySections,
      ],
      if (request.trailingSections.isNotEmpty) ...[
        ...request.trailingSections,
      ],
      const SizedBox(height: 6),
    ];

    return LibraryDetailsPaneFrame(
      accentColor: accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        children: children,
      ),
    );
  }
}
