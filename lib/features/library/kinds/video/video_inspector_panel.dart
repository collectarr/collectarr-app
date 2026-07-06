import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_shared_sections.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_sections.dart';
import 'package:flutter/material.dart';

Widget buildVideoInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return VideoInspectorPanel(request: request);
}

class VideoInspectorPanel extends StatelessWidget {
  const VideoInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final entry = request.inspector.entry;
    final ownedItem = request.inspector.ownedItem;
    final accent = request.inspector.accent;
    final sections = buildVideoInspectorSections(context, request.inspector);

    return LibraryInspectorPanelLayout(
      entry: entry,
      ownedItem: ownedItem,
      accent: accent,
      children: [
        InspectorUnifiedToolbar(
          entry: entry,
          detailsLayout: request.inspector.detailsLayout,
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
        LibraryDetailHero(
          type: request.inspector.type,
          entry: entry,
          ownedItem: ownedItem,
          accent: accent,
        ),
        ...buildLibraryInspectorSectionFlow(
          bodySections: [
            request.ownedCopiesSection,
            request.bundleSection,
            request.conditionGradeSection,
            ...sections,
          ],
          afterBodySections: request.trailingSections,
        ),
      ],
    );
  }
}
